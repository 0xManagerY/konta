import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/invoice_template_repository.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/presentation/providers/team_provider.dart';
import 'package:konta/core/utils/logger.dart';

final invoiceTemplateRepositoryProvider = Provider<InvoiceTemplateRepository>((
  ref,
) {
  Logger.method('Provider', 'invoiceTemplateRepositoryProvider', {
    'init': true,
  });
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return InvoiceTemplateRepository(db, syncQueue);
});

final invoiceTemplatesProvider =
    AsyncNotifierProvider<InvoiceTemplatesNotifier, List<InvoiceTemplate>>(() {
      return InvoiceTemplatesNotifier();
    });

class InvoiceTemplatesNotifier extends AsyncNotifier<List<InvoiceTemplate>> {
  @override
  Future<List<InvoiceTemplate>> build() async {
    Logger.method('Provider', 'InvoiceTemplatesNotifier.build', {
      'watch': true,
    });
    final repo = ref.watch(invoiceTemplateRepositoryProvider);
    final companyId = _getCurrentCompanyId();
    if (companyId == null) {
      Logger.warning(
        'No company ID, returning empty templates',
        tag: 'INVOICE_TEMPLATE_PROVIDER',
      );
      return [];
    }
    return repo.getTemplatesByCompany(companyId);
  }

  String? _getCurrentCompanyId() {
    try {
      return ref.read(currentCompanyProvider).valueOrNull?.id;
    } catch (e) {
      Logger.warning(
        'Could not get company ID',
        tag: 'INVOICE_TEMPLATE_PROVIDER',
      );
      return null;
    }
  }

  Future<void> refresh() async {
    Logger.method('Provider', 'InvoiceTemplatesNotifier.refresh', {});
    final repo = ref.read(invoiceTemplateRepositoryProvider);
    final companyId = _getCurrentCompanyId();
    if (companyId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.getTemplatesByCompany(companyId));
  }

  Future<void> updateTemplate(InvoiceTemplate template) async {
    Logger.method('Provider', 'InvoiceTemplatesNotifier.updateTemplate', {
      'id': template.id,
    });
    final repo = ref.read(invoiceTemplateRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.updateTemplate(template);
      final companyId = _getCurrentCompanyId();
      if (companyId == null) return <InvoiceTemplate>[];
      return repo.getTemplatesByCompany(companyId);
    });
  }

  Future<void> setDefault(String templateId) async {
    Logger.method('Provider', 'InvoiceTemplatesNotifier.setDefault', {
      'templateId': templateId,
    });
    final repo = ref.read(invoiceTemplateRepositoryProvider);
    final companyId = _getCurrentCompanyId();
    if (companyId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.setDefaultTemplate(companyId, templateId);
      return repo.getTemplatesByCompany(companyId);
    });
  }
}

final selectedTemplateProvider = StateProvider<InvoiceTemplate?>((ref) => null);

final currentCompanyProvider = StreamProvider<Company?>((ref) {
  return Stream.value(null);
});
