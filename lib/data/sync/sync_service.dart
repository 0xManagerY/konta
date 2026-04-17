import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/data/remote/storage_service.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef SyncFailureCallback =
    void Function({
      required String table,
      required String operation,
      required String recordId,
      required String error,
      bool isPermanentFailure,
    });

class SyncService {
  final AppDatabase _db;
  final LogService _log = LogService();

  static const int maxSyncRetries = 5;

  SyncService(this._db);

  Future<void> syncAll({
    String? companyId,
    SyncFailureCallback? onFailure,
  }) async {
    if (!SupabaseService.isAuthenticated) {
      _log.info(LogTags.sync, 'syncAll - skipped: user not authenticated');
      return;
    }

    if (companyId == null) {
      _log.info(LogTags.sync, 'syncAll - skipped: no company selected');
      return;
    }

    _log.info(
      LogTags.sync,
      'syncAll - starting',
      data: {'companyId': companyId},
    );
    try {
      await _pushPendingChanges(companyId, onFailure: onFailure);
      await _pullRemoteChanges(companyId);
      _log.info(LogTags.sync, 'syncAll - completed');
    } catch (e, st) {
      _log.error(LogTags.sync, 'syncAll - failed', error: e, stack: st);
    }
  }

  Future<void> _pushPendingChanges(
    String companyId, {
    SyncFailureCallback? onFailure,
  }) async {
    final operations = await getPendingOperations();
    _log.debug(
      LogTags.sync,
      '_pushPendingChanges - processing',
      data: {'count': operations.length},
    );

    for (final op in operations) {
      _log.debug(
        LogTags.sync,
        '_pushPendingChanges - operation',
        data: {
          'operation': op.operation,
          'table': op.tblName,
          'recordId': op.recordId,
        },
      );
      try {
        final success = await _pushOperation(op, companyId);
        if (success) {
          await markSynced(op.id);
          await markRecordSynced(op.tblName, op.recordId);
          _log.debug(
            LogTags.sync,
            '_pushPendingChanges - success',
            data: {'table': op.tblName, 'id': op.recordId},
          );
        } else {
          await incrementRetry(op.id, onFailure: onFailure);
        }
      } catch (e, st) {
        await incrementRetry(op.id, onFailure: onFailure);
        _log.error(
          LogTags.sync,
          '_pushPendingChanges - failed',
          error: e,
          stack: st,
          data: {
            'operation': op.operation,
            'table': op.tblName,
            'recordId': op.recordId,
          },
        );
        onFailure?.call(
          table: op.tblName,
          operation: op.operation,
          recordId: op.recordId,
          error: e.toString(),
        );
      }
    }
  }

  Future<bool> _pushOperation(SyncQueueItem op, String companyId) async {
    var data = await getRecord(op.tblName, op.recordId);
    if (data == null) {
      _log.warn(
        LogTags.sync,
        '_pushOperation - record not found',
        data: {'table': op.tblName, 'id': op.recordId},
      );
      return false;
    }

    final client = SupabaseService.client;
    final userId = SupabaseService.currentUserId;

    _log.debug(
      LogTags.supabase,
      '_pushOperation - push data',
      data: {'table': op.tblName, 'data': jsonEncode(data)},
    );

    if (op.tblName == 'expenses' &&
        op.operation != 'delete' &&
        userId != null) {
      final receiptLocalPath = data['receipt_local_path'] as String?;
      final receiptUrl = data['receipt_url'] as String?;

      if (receiptLocalPath != null &&
          receiptLocalPath.isNotEmpty &&
          StorageService.isLocalPath(receiptLocalPath) &&
          (receiptUrl == null ||
              receiptUrl.isEmpty ||
              StorageService.isLocalPath(receiptUrl))) {
        _log.debug(
          LogTags.sync,
          '_pushOperation - uploading receipt',
          data: {'path': receiptLocalPath},
        );
        final remoteUrl = await StorageService.uploadReceipt(
          localPath: receiptLocalPath,
          userId: userId,
        );
        if (remoteUrl != null) {
          data = Map<String, dynamic>.from(data);
          data['receipt_url'] = remoteUrl;
          await _updateExpenseReceiptUrls(
            op.recordId,
            remoteUrl,
            receiptLocalPath,
          );
          _log.debug(
            LogTags.sync,
            '_pushOperation - receipt uploaded',
            data: {'url': remoteUrl},
          );
        }
      }
    }

    final tableName = _mapTableName(op.tblName);

    switch (op.operation) {
      case 'delete':
        _log.debug(
          LogTags.supabase,
          '_pushOperation - delete',
          data: {'table': tableName, 'id': op.recordId},
        );
        await client.from(tableName).delete().eq('id', op.recordId);
        break;
      default:
        _log.debug(
          LogTags.supabase,
          '_pushOperation - upsert',
          data: {'table': tableName},
        );
        await client.from(tableName).upsert(data, onConflict: 'id');
    }

    return true;
  }

  String _mapTableName(String oldName) {
    switch (oldName) {
      case 'customers':
        return 'contacts';
      case 'products':
        return 'items';
      case 'invoices':
        return 'documents';
      case 'invoice_items':
        return 'document_lines';
      case 'user_profiles':
        return 'user_profiles';
      case 'companies':
        return 'companies';
      case 'company_users':
        return 'company_users';
      case 'taxes':
        return 'taxes';
      case 'expenses':
        return 'expenses';
      case 'payments':
        return 'payments';
      default:
        return oldName;
    }
  }

  Future<void> _pullRemoteChanges(String companyId) async {
    final client = SupabaseService.client;

    _log.debug(LogTags.sync, '_pullRemoteChanges - pulling companies');
    await _pullTable('companies', companyId, client);

    _log.debug(LogTags.sync, '_pullRemoteChanges - pulling taxes');
    await _pullTable('taxes', companyId, client);

    _log.debug(LogTags.sync, '_pullRemoteChanges - pulling items');
    await _pullTable('items', companyId, client);

    _log.debug(LogTags.sync, '_pullRemoteChanges - pulling contacts');
    await _pullTable('contacts', companyId, client);

    _log.debug(LogTags.sync, '_pullRemoteChanges - pulling documents');
    await _pullTable('documents', companyId, client);

    _log.debug(LogTags.sync, '_pullRemoteChanges - pulling document_lines');
    await _pullDocumentLines(companyId, client);

    _log.debug(LogTags.sync, '_pullRemoteChanges - pulling expenses');
    await _pullTable('expenses', companyId, client);

    _log.debug(LogTags.sync, '_pullRemoteChanges - pulling payments');
    await _pullPayments(companyId, client);
  }

  Future<void> _pullTable(
    String table,
    String companyId,
    SupabaseClient client,
  ) async {
    final response = await client
        .from(table)
        .select()
        .eq('company_id', companyId)
        .eq('sync_status', 'synced');

    _log.debug(
      LogTags.sync,
      '_pullTable - fetched',
      data: {'table': table, 'count': response.length},
    );

    for (final row in response) {
      await _upsertLocal(table, row);
    }
  }

  Future<void> _pullDocumentLines(
    String companyId,
    SupabaseClient client,
  ) async {
    final documents = await client
        .from('documents')
        .select('id')
        .eq('company_id', companyId);

    for (final doc in documents) {
      final response = await client
          .from('document_lines')
          .select()
          .eq('document_id', doc['id']);
      _log.debug(
        LogTags.sync,
        '_pullDocumentLines - fetched',
        data: {'documentId': doc['id'], 'count': response.length},
      );
      for (final row in response) {
        await _upsertLocal('document_lines', row);
      }
    }
  }

  Future<void> _pullPayments(String companyId, SupabaseClient client) async {
    final documents = await client
        .from('documents')
        .select('id')
        .eq('company_id', companyId);

    for (final doc in documents) {
      final response = await client
          .from('payments')
          .select()
          .eq('document_id', doc['id']);
      _log.debug(
        LogTags.sync,
        '_pullPayments - fetched',
        data: {'documentId': doc['id'], 'count': response.length},
      );
      for (final row in response) {
        await _upsertLocal('payments', row);
      }
    }
  }

  Future<void> _upsertLocal(String table, Map<String, dynamic> data) async {
    switch (table) {
      case 'items':
        final existing = await (_db.select(
          _db.items,
        )..where((i) => i.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          _log.debug(
            LogTags.db,
            '_upsertLocal - items',
            data: {'id': data['id']},
          );
          final item = Item(
            id: data['id'] as String,
            companyId: data['company_id'] as String,
            name: data['name'] as String,
            description: data['description'] as String?,
            defaultUnitPrice:
                (data['default_unit_price'] as num?)?.toDouble() ?? 0,
            defaultTaxId: data['default_tax_id'] as String?,
            category: data['category'] as String?,
            isActive: data['is_active'] as bool? ?? true,
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.items).insertOnConflictUpdate(item);
        } else {
          _log.debug(
            LogTags.sync,
            '_upsertLocal - skip conflict',
            data: {'table': 'items', 'id': data['id']},
          );
        }
        break;

      case 'contacts':
        final existing = await (_db.select(
          _db.contacts,
        )..where((c) => c.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          _log.debug(
            LogTags.db,
            '_upsertLocal - contacts',
            data: {'id': data['id']},
          );
          final contact = Contact(
            id: data['id'] as String,
            companyId: data['company_id'] as String,
            name: data['name'] as String,
            contactType: data['contact_type'] as String? ?? 'customer',
            ice: data['ice'] as String?,
            rc: data['rc'] as String?,
            ifNumber: data['if_number'] as String?,
            patente: data['patente'] as String?,
            cnss: data['cnss'] as String?,
            legalForm: data['legal_form'] as String?,
            capital: data['capital'] as String?,
            address: data['address'] as String?,
            phones: data['phones'] as String?,
            fax: data['fax'] as String?,
            emails: data['emails'] as String?,
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.contacts).insertOnConflictUpdate(contact);
        } else {
          _log.debug(
            LogTags.sync,
            '_upsertLocal - skip conflict',
            data: {'table': 'contacts', 'id': data['id']},
          );
        }
        break;

      case 'documents':
        final existing = await (_db.select(
          _db.documents,
        )..where((d) => d.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          _log.debug(
            LogTags.db,
            '_upsertLocal - documents',
            data: {'id': data['id']},
          );
          final document = Document(
            id: data['id'] as String,
            companyId: data['company_id'] as String,
            contactId: data['contact_id'] as String,
            type: DocumentType.values.firstWhere(
              (e) => e.name == data['type'],
              orElse: () => DocumentType.invoice,
            ),
            number: data['number'] as String,
            status: DocumentStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => DocumentStatus.draft,
            ),
            issueDate: DateTime.parse(data['issue_date'] as String),
            dueDate: data['due_date'] != null
                ? DateTime.parse(data['due_date'] as String)
                : null,
            subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
            tvaAmount: (data['tva_amount'] as num?)?.toDouble() ?? 0.0,
            total: (data['total'] as num?)?.toDouble() ?? 0.0,
            notes: data['notes'] as String?,
            parentDocumentId: data['parent_document_id'] as String?,
            parentDocumentType: data['parent_document_type'] as String?,
            refundReason: data['refund_reason'] as String?,
            isConverted: data['is_converted'] as bool? ?? false,
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.documents).insertOnConflictUpdate(document);
        } else {
          _log.debug(
            LogTags.sync,
            '_upsertLocal - skip conflict',
            data: {'table': 'documents', 'id': data['id']},
          );
        }
        break;

      case 'document_lines':
        final existingItem = await (_db.select(
          _db.documentLines,
        )..where((dl) => dl.id.equals(data['id']))).getSingleOrNull();

        if (existingItem == null || existingItem.syncStatus == 'synced') {
          _log.debug(
            LogTags.db,
            '_upsertLocal - document_lines',
            data: {'id': data['id']},
          );
          final line = DocumentLine(
            id: data['id'] as String,
            documentId: data['document_id'] as String,
            itemId: data['item_id'] as String?,
            description: data['description'] as String? ?? '',
            quantity: (data['quantity'] as num?)?.toDouble() ?? 1.0,
            unitPrice: (data['unit_price'] as num).toDouble(),
            taxId: data['tax_id'] as String?,
            tvaRate: (data['tva_rate'] as num?)?.toDouble() ?? 0.0,
            total: (data['total'] as num).toDouble(),
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.documentLines).insertOnConflictUpdate(line);
        } else {
          _log.debug(
            LogTags.sync,
            '_upsertLocal - skip conflict',
            data: {'table': 'document_lines', 'id': data['id']},
          );
        }
        break;

      case 'expenses':
        final existing = await (_db.select(
          _db.expenses,
        )..where((e) => e.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          _log.debug(
            LogTags.db,
            '_upsertLocal - expenses',
            data: {'id': data['id']},
          );
          final expense = Expense(
            id: data['id'] as String,
            companyId: data['company_id'] as String,
            category: data['category'] as String,
            amount: (data['amount'] as num).toDouble(),
            tvaAmount: (data['tva_amount'] as num?)?.toDouble() ?? 0.0,
            date: DateTime.parse(data['date'] as String),
            description: data['description'] as String?,
            receiptUrl: data['receipt_url'] as String?,
            receiptLocalPath: data['receipt_local_path'] as String?,
            isDeductible: data['is_deductible'] as bool? ?? true,
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.expenses).insertOnConflictUpdate(expense);
        } else {
          _log.debug(
            LogTags.sync,
            '_upsertLocal - skip conflict',
            data: {'table': 'expenses', 'id': data['id']},
          );
        }
        break;

      case 'payments':
        final existing = await (_db.select(
          _db.payments,
        )..where((p) => p.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          _log.debug(
            LogTags.db,
            '_upsertLocal - payments',
            data: {'id': data['id']},
          );
          final payment = Payment(
            id: data['id'] as String,
            companyId: data['company_id'] as String,
            documentId: data['document_id'] as String,
            amount: (data['amount'] as num).toDouble(),
            method: data['method'] as String,
            paymentDate: DateTime.parse(data['payment_date'] as String),
            checkDueDate: data['check_due_date'] != null
                ? DateTime.parse(data['check_due_date'] as String)
                : null,
            notes: data['notes'] as String?,
            createdAt: DateTime.parse(data['created_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.payments).insertOnConflictUpdate(payment);
        } else {
          _log.debug(
            LogTags.sync,
            '_upsertLocal - skip conflict',
            data: {'table': 'payments', 'id': data['id']},
          );
        }
        break;

      case 'taxes':
        final existing = await (_db.select(
          _db.taxes,
        )..where((t) => t.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          _log.debug(
            LogTags.db,
            '_upsertLocal - taxes',
            data: {'id': data['id']},
          );
          final tax = Tax(
            id: data['id'] as String,
            companyId: data['company_id'] as String,
            name: data['name'] as String,
            rate: (data['rate'] as num).toDouble(),
            description: data['description'] as String?,
            isActive: data['is_active'] as bool? ?? true,
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.taxes).insertOnConflictUpdate(tax);
        } else {
          _log.debug(
            LogTags.sync,
            '_upsertLocal - skip conflict',
            data: {'table': 'taxes', 'id': data['id']},
          );
        }
        break;

      case 'companies':
        final existing = await (_db.select(
          _db.companies,
        )..where((c) => c.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          _log.debug(
            LogTags.db,
            '_upsertLocal - companies',
            data: {'id': data['id']},
          );
          final company = Company(
            id: data['id'] as String,
            name: data['name'] as String,
            legalStatus: data['legal_status'] as String? ?? 'SARL',
            ice: data['ice'] as String?,
            ifNumber: data['if_number'] as String?,
            rc: data['rc'] as String?,
            cnss: data['cnss'] as String?,
            address: data['address'] as String?,
            phone: data['phone'] as String?,
            logoUrl: data['logo_url'] as String?,
            isAutoEntrepreneur: data['is_auto_entrepreneur'] as bool? ?? false,
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.companies).insertOnConflictUpdate(company);
        } else {
          _log.debug(
            LogTags.sync,
            '_upsertLocal - skip conflict',
            data: {'table': 'companies', 'id': data['id']},
          );
        }
        break;
    }
  }

  Future<void> queueOperation({
    required String table,
    required String operation,
    required String recordId,
    Map<String, dynamic>? data,
  }) async {
    _log.debug(
      LogTags.sync,
      'queueOperation - queuing',
      data: {'table': table, 'operation': operation, 'recordId': recordId},
    );
    await _db
        .into(_db.syncQueue)
        .insert(
          SyncQueueCompanion(
            tblName: Value(table),
            operation: Value(operation),
            recordId: Value(recordId),
            data: Value(data != null ? jsonEncode(data) : null),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<SyncQueueItem>> getPendingOperations() async {
    return (_db.select(
      _db.syncQueue,
    )..orderBy([(q) => OrderingTerm.asc(q.createdAt)])).get();
  }

  Future<void> markSynced(int queueId) async {
    _log.debug(
      LogTags.db,
      'markSynced - deleting from queue',
      data: {'id': queueId},
    );
    await (_db.delete(_db.syncQueue)..where((q) => q.id.equals(queueId))).go();
  }

  Future<void> incrementRetry(
    int queueId, {
    SyncFailureCallback? onFailure,
  }) async {
    final item = await (_db.select(
      _db.syncQueue,
    )..where((q) => q.id.equals(queueId))).getSingle();
    final newRetryCount = item.retryCount + 1;

    _log.debug(
      LogTags.sync,
      'incrementRetry - retry count',
      data: {'queueId': queueId, 'count': newRetryCount},
    );

    if (newRetryCount >= maxSyncRetries) {
      _log.error(
        LogTags.sync,
        'incrementRetry - MAX_RETRIES_EXCEEDED',
        data: {
          'queueId': queueId,
          'table': item.tblName,
          'recordId': item.recordId,
          'operation': item.operation,
        },
      );
      onFailure?.call(
        table: item.tblName,
        operation: item.operation,
        recordId: item.recordId,
        error: 'MAX_RETRIES_EXCEEDED',
        isPermanentFailure: true,
      );
      return;
    }

    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(queueId))).write(
      SyncQueueCompanion(retryCount: Value(newRetryCount)),
    );
  }

  Future<Map<String, dynamic>?> getRecord(String table, String id) async {
    switch (table) {
      case 'companies':
        final record = await (_db.select(
          _db.companies,
        )..where((c) => c.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'name': record.name,
          'legal_status': record.legalStatus,
          'ice': record.ice,
          'if_number': record.ifNumber,
          'rc': record.rc,
          'cnss': record.cnss,
          'address': record.address,
          'phone': record.phone,
          'logo_url': record.logoUrl,
          'is_auto_entrepreneur': record.isAutoEntrepreneur,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };

      case 'contacts':
        final record = await (_db.select(
          _db.contacts,
        )..where((c) => c.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'company_id': record.companyId,
          'name': record.name,
          'contact_type': record.contactType,
          'ice': record.ice,
          'rc': record.rc,
          'if_number': record.ifNumber,
          'patente': record.patente,
          'cnss': record.cnss,
          'legal_form': record.legalForm,
          'capital': record.capital,
          'address': record.address,
          'phones': record.phones,
          'fax': record.fax,
          'emails': record.emails,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };

      case 'items':
        final record = await (_db.select(
          _db.items,
        )..where((i) => i.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'company_id': record.companyId,
          'name': record.name,
          'description': record.description,
          'default_unit_price': record.defaultUnitPrice,
          'default_tax_id': record.defaultTaxId,
          'category': record.category,
          'is_active': record.isActive,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };

      case 'taxes':
        final record = await (_db.select(
          _db.taxes,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'company_id': record.companyId,
          'name': record.name,
          'rate': record.rate,
          'description': record.description,
          'is_active': record.isActive,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };

      case 'documents':
        final record = await (_db.select(
          _db.documents,
        )..where((d) => d.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'company_id': record.companyId,
          'contact_id': record.contactId,
          'type': record.type.name,
          'number': record.number,
          'status': record.status.name,
          'issue_date': record.issueDate.toIso8601String(),
          'due_date': record.dueDate?.toIso8601String(),
          'subtotal': record.subtotal,
          'tva_amount': record.tvaAmount,
          'total': record.total,
          'notes': record.notes,
          'parent_document_id': record.parentDocumentId,
          'parent_document_type': record.parentDocumentType,
          'refund_reason': record.refundReason,
          'is_converted': record.isConverted,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };

      case 'document_lines':
        final record = await (_db.select(
          _db.documentLines,
        )..where((dl) => dl.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'document_id': record.documentId,
          'item_id': record.itemId,
          'description': record.description,
          'quantity': record.quantity,
          'unit_price': record.unitPrice,
          'tax_id': record.taxId,
          'tva_rate': record.tvaRate,
          'total': record.total,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };

      case 'expenses':
        final record = await (_db.select(
          _db.expenses,
        )..where((e) => e.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'company_id': record.companyId,
          'category': record.category,
          'amount': record.amount,
          'tva_amount': record.tvaAmount,
          'date': record.date.toIso8601String(),
          'description': record.description,
          'receipt_url': record.receiptUrl,
          'receipt_local_path': record.receiptLocalPath,
          'is_deductible': record.isDeductible,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };

      case 'payments':
        final record = await (_db.select(
          _db.payments,
        )..where((p) => p.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'company_id': record.companyId,
          'document_id': record.documentId,
          'amount': record.amount,
          'method': record.method,
          'payment_date': record.paymentDate.toIso8601String(),
          'check_due_date': record.checkDueDate?.toIso8601String(),
          'notes': record.notes,
          'created_at': record.createdAt.toIso8601String(),
        };

      default:
        return null;
    }
  }

  Future<void> markRecordSynced(String table, String id) async {
    final now = DateTime.now();
    _log.debug(
      LogTags.db,
      'markRecordSynced - marking synced',
      data: {'table': table, 'id': id},
    );

    switch (table) {
      case 'companies':
        await (_db.update(_db.companies)..where((c) => c.id.equals(id))).write(
          CompaniesCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'contacts':
        await (_db.update(_db.contacts)..where((c) => c.id.equals(id))).write(
          ContactsCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'items':
        await (_db.update(_db.items)..where((i) => i.id.equals(id))).write(
          ItemsCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'taxes':
        await (_db.update(_db.taxes)..where((t) => t.id.equals(id))).write(
          TaxesCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'documents':
        await (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(
          DocumentsCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'document_lines':
        await (_db.update(
          _db.documentLines,
        )..where((dl) => dl.id.equals(id))).write(
          DocumentLinesCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'expenses':
        await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
          ExpensesCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'payments':
        await (_db.update(_db.payments)..where((p) => p.id.equals(id))).write(
          PaymentsCompanion(syncStatus: const Value('synced')),
        );
        break;
    }
  }

  Future<void> _updateExpenseReceiptUrls(
    String expenseId,
    String remoteUrl,
    String localPath,
  ) async {
    await (_db.update(
      _db.expenses,
    )..where((e) => e.id.equals(expenseId))).write(
      ExpensesCompanion(
        receiptUrl: Value(remoteUrl),
        receiptLocalPath: Value(localPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
    _log.debug(
      LogTags.db,
      '_updateExpenseReceiptUrls - updated',
      data: {'id': expenseId, 'url': remoteUrl, 'local': localPath},
    );
  }

  Future<int> getPendingCount() async {
    final items = await (_db.select(_db.syncQueue)).get();
    return items.length;
  }

  Future<void> clearQueue() async {
    _log.info(LogTags.sync, 'clearQueue - clearing sync queue');
    await (_db.delete(_db.syncQueue)).go();
  }

  Stream<bool> get syncStatus =>
      Stream.periodic(const Duration(seconds: 30), (_) => true).asyncMap((
        _,
      ) async {
        _log.debug(LogTags.sync, 'syncStatus - auto sync triggered');
        await syncAll();
        return true;
      });

  Stream<bool> syncStatusWithSetting(bool enabled, {String? companyId}) {
    if (!enabled) {
      _log.info(LogTags.sync, 'syncStatusWithSetting - auto sync disabled');
      return Stream.value(false);
    }
    return Stream.periodic(const Duration(seconds: 30), (_) => true).asyncMap((
      _,
    ) async {
      await syncAll(companyId: companyId);
      return true;
    });
  }
}
