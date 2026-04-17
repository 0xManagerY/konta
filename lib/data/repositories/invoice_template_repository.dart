import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class InvoiceTemplateRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;

  InvoiceTemplateRepository(this._db, this._syncQueue);

  Future<List<InvoiceTemplate>> getTemplatesByCompany(String companyId) async {
    Logger.debug('Fetching templates for company', tag: 'InvoiceTemplateRepo');
    try {
      final result =
          await (_db.select(_db.invoiceTemplates)
                ..where(
                  (t) => t.companyId.equals(companyId) | t.companyId.isNull(),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.name)]))
              .get();
      Logger.info(
        'Retrieved ${result.length} templates',
        tag: 'InvoiceTemplateRepo',
      );
      return result;
    } catch (e, st) {
      Logger.error(
        'Failed to fetch templates',
        tag: 'InvoiceTemplateRepo',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<InvoiceTemplate?> getTemplateById(String id) async {
    Logger.debug('Fetching template', tag: 'InvoiceTemplateRepo');
    try {
      final result = await (_db.select(
        _db.invoiceTemplates,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      Logger.info(
        'Template found: ${result != null}',
        tag: 'InvoiceTemplateRepo',
      );
      return result;
    } catch (e, st) {
      Logger.error(
        'Failed to fetch template',
        tag: 'InvoiceTemplateRepo',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<InvoiceTemplate?> getCompanyDefaultTemplate(String companyId) async {
    Logger.debug(
      'Fetching default template for company',
      tag: 'InvoiceTemplateRepo',
    );
    try {
      final result =
          await (_db.select(_db.invoiceTemplates)
                ..where((t) => t.companyId.equals(companyId))
                ..where((t) => t.isDefault.equals(true)))
              .getSingleOrNull();
      Logger.info(
        'Default template found: ${result != null}',
        tag: 'InvoiceTemplateRepo',
      );
      return result;
    } catch (e, st) {
      Logger.error(
        'Failed to fetch default template',
        tag: 'InvoiceTemplateRepo',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<InvoiceTemplate> createTemplate(
    String companyId,
    InvoiceTemplatesCompanion template,
  ) async {
    Logger.debug('Creating template', tag: 'InvoiceTemplateRepo');
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final isFirstTemplate =
          await (_db.select(_db.invoiceTemplates)
                ..where((t) => t.companyId.equals(companyId)))
              .get()
              .then((templates) => templates.isEmpty);

      final newTemplate = InvoiceTemplate(
        id: id,
        companyId: companyId,
        name: template.name.value,
        description: template.description.value,
        headerStyle: template.headerStyle.value,
        primaryColor: template.primaryColor.value,
        showCustomerIce: template.showCustomerIce.value,
        showPaymentTerms: template.showPaymentTerms.value,
        showProductSkus: template.showProductSkus.value,
        footerText: template.footerText.value,
        isDefault: isFirstTemplate ? true : (template.isDefault.value),
        createdAt: now,
        updatedAt: now,
      );

      await _db.into(_db.invoiceTemplates).insert(newTemplate);
      await _syncQueue.queueInsert('invoice_templates', id);

      Logger.info('Created template: $id', tag: 'InvoiceTemplateRepo');
      return newTemplate;
    } catch (e, st) {
      Logger.error(
        'Failed to create template',
        tag: 'InvoiceTemplateRepo',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<InvoiceTemplate> updateTemplate(InvoiceTemplate template) async {
    Logger.debug('Updating template', tag: 'InvoiceTemplateRepo');
    try {
      final now = DateTime.now();

      await (_db.update(
        _db.invoiceTemplates,
      )..where((t) => t.id.equals(template.id))).write(
        InvoiceTemplatesCompanion(
          name: Value(template.name),
          description: Value(template.description),
          headerStyle: Value(template.headerStyle),
          primaryColor: Value(template.primaryColor),
          showCustomerIce: Value(template.showCustomerIce),
          showPaymentTerms: Value(template.showPaymentTerms),
          showProductSkus: Value(template.showProductSkus),
          footerText: Value(template.footerText),
          isDefault: Value(template.isDefault),
          updatedAt: Value(now),
        ),
      );

      await _syncQueue.queueUpdate('invoice_templates', template.id);

      final updated = await getTemplateById(template.id);
      Logger.info(
        'Updated template: ${template.id}',
        tag: 'InvoiceTemplateRepo',
      );
      return updated!;
    } catch (e, st) {
      Logger.error(
        'Failed to update template',
        tag: 'InvoiceTemplateRepo',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> setDefaultTemplate(String companyId, String templateId) async {
    Logger.debug('Setting default template', tag: 'InvoiceTemplateRepo');
    try {
      await _db.transaction(() async {
        await (_db.update(_db.invoiceTemplates)
              ..where((t) => t.companyId.equals(companyId)))
            .write(const InvoiceTemplatesCompanion(isDefault: Value(false)));

        await (_db.update(_db.invoiceTemplates)
              ..where((t) => t.id.equals(templateId)))
            .write(const InvoiceTemplatesCompanion(isDefault: Value(true)));
      });

      await _syncQueue.queueUpdate('invoice_templates', templateId);

      Logger.info(
        'Set default template: $templateId',
        tag: 'InvoiceTemplateRepo',
      );
    } catch (e, st) {
      Logger.error(
        'Failed to set default template',
        tag: 'InvoiceTemplateRepo',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    Logger.debug('Deleting template', tag: 'InvoiceTemplateRepo');
    try {
      final template = await getTemplateById(templateId);
      if (template != null && template.companyId != null) {
        await _syncQueue.queueDelete('invoice_templates', templateId);
        await (_db.delete(
          _db.invoiceTemplates,
        )..where((t) => t.id.equals(templateId))).go();
        Logger.info(
          'Deleted template: $templateId',
          tag: 'InvoiceTemplateRepo',
        );
      } else {
        Logger.info(
          'Cannot delete default template: $templateId',
          tag: 'InvoiceTemplateRepo',
        );
      }
    } catch (e, st) {
      Logger.error(
        'Failed to delete template',
        tag: 'InvoiceTemplateRepo',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
