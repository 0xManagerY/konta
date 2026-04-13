import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/remote/storage_service.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  final AppDatabase _db;

  SyncService(this._db);

  Future<void> syncAll() async {
    if (!SupabaseService.isAuthenticated) {
      Logger.sync('SYNC_SKIPPED', 'User not authenticated');
      return;
    }

    Logger.sync('SYNC_START', 'Pushing pending changes');
    await _pushPendingChanges();
    Logger.sync('SYNC_PULL', 'Pulling remote changes');
    await _pullRemoteChanges();
    Logger.sync('SYNC_COMPLETE');
  }

  Future<void> _pushPendingChanges() async {
    final operations = await getPendingOperations();
    Logger.sync('PUSH_QUEUE', '${operations.length} pending operations');

    for (final op in operations) {
      Logger.sync(
        'PUSH_OP',
        '${op.operation} on ${op.tblName} (id: ${op.recordId})',
      );
      try {
        final success = await _pushOperation(op);
        if (success) {
          await markSynced(op.id);
          await markRecordSynced(op.tblName, op.recordId);
          Logger.sync('PUSH_SUCCESS', '${op.tblName}/${op.recordId}');
        } else {
          await incrementRetry(op.id);
          Logger.warning('PUSH_RETRY', tag: 'SYNC');
        }
      } catch (e, st) {
        await incrementRetry(op.id);
        Logger.error('PUSH_FAILED', tag: 'SYNC', error: e, stackTrace: st);
      }
    }
  }

  Future<bool> _pushOperation(SyncQueueItem op) async {
    var data = await getRecord(op.tblName, op.recordId);
    if (data == null) {
      Logger.warning('RECORD_NOT_FOUND', tag: 'SYNC');
      return false;
    }

    final client = SupabaseService.client;
    final userId = SupabaseService.currentUserId;

    Logger.sync('PUSH_DATA', '${op.tblName}: ${jsonEncode(data)}');

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
        Logger.sync('UPLOAD_RECEIPT', receiptLocalPath);
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
          Logger.sync('RECEIPT_UPLOADED', remoteUrl);
        }
      }
    }

    switch (op.tblName) {
      case 'profiles':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'profiles/${op.recordId}');
          await client.from('profiles').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'profiles', data);
          await client.from('profiles').upsert(data, onConflict: 'id');
        }
        break;
      case 'customers':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'customers/${op.recordId}');
          await client.from('customers').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'customers', data);
          await client.from('customers').upsert(data, onConflict: 'id');
        }
        break;
      case 'products':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'products/${op.recordId}');
          await client.from('products').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'products', data);
          await client.from('products').upsert(data, onConflict: 'id');
        }
        break;
      case 'invoices':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'invoices/${op.recordId}');
          await client.from('invoices').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'invoices', data);
          await client.from('invoices').upsert(data, onConflict: 'id');
        }
        break;
      case 'invoice_items':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'invoice_items/${op.recordId}');
          await client.from('invoice_items').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'invoice_items', data);
          await client.from('invoice_items').upsert(data, onConflict: 'id');
        }
        break;
      case 'expenses':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'expenses/${op.recordId}');
          await client.from('expenses').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'expenses', data);
          await client.from('expenses').upsert(data, onConflict: 'id');
        }
        break;
      case 'payments':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'payments/${op.recordId}');
          await client.from('payments').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'payments', data);
          await client.from('payments').upsert(data, onConflict: 'id');
        }
        break;
      case 'owner_salaries':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'owner_salaries/${op.recordId}');
          await client.from('owner_salaries').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'owner_salaries', data);
          await client.from('owner_salaries').upsert(data, onConflict: 'id');
        }
        break;
      default:
        Logger.warning('UNKNOWN_TABLE: ${op.tblName}', tag: 'SYNC');
        return false;
    }

    return true;
  }

  Future<void> _pullRemoteChanges() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      Logger.sync('PULL_SKIPPED', 'No user ID');
      return;
    }

    final client = SupabaseService.client;

    Logger.sync('PULL_TABLE', 'profiles');
    await _pullProfiles(userId, client);
    Logger.sync('PULL_TABLE', 'products');
    await _pullTable('products', userId, client);
    Logger.sync('PULL_TABLE', 'customers');
    await _pullTable('customers', userId, client);
    Logger.sync('PULL_TABLE', 'invoices');
    await _pullTable('invoices', userId, client);
    Logger.sync('PULL_TABLE', 'invoice_items');
    await _pullInvoiceItems(userId, client);
    Logger.sync('PULL_TABLE', 'expenses');
    await _pullTable('expenses', userId, client);
    Logger.sync('PULL_TABLE', 'payments');
    await _pullPayments(userId, client);
  }

  Future<void> _pullProfiles(String userId, SupabaseClient client) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response != null) {
      Logger.sync('PULL_ROWS', 'profiles: 1 record');
      await _upsertProfileLocal(response);
    }
  }

  Future<void> _pullInvoiceItems(String userId, SupabaseClient client) async {
    final invoices = await client
        .from('invoices')
        .select('id')
        .eq('user_id', userId);

    for (final inv in invoices) {
      final response = await client
          .from('invoice_items')
          .select()
          .eq('invoice_id', inv['id']);
      Logger.sync(
        'PULL_ROWS',
        'invoice_items: ${response.length} for ${inv['id']}',
      );
      for (final row in response) {
        await _upsertLocal('invoice_items', row);
      }
    }
  }

  Future<void> _pullPayments(String userId, SupabaseClient client) async {
    final invoices = await client
        .from('invoices')
        .select('id')
        .eq('user_id', userId);

    for (final inv in invoices) {
      final response = await client
          .from('payments')
          .select()
          .eq('invoice_id', inv['id']);
      Logger.sync('PULL_ROWS', 'payments: ${response.length} for ${inv['id']}');
      for (final row in response) {
        await _upsertPaymentLocal(row);
      }
    }
  }

  Future<void> _pullTable(
    String table,
    String userId,
    SupabaseClient client,
  ) async {
    final response = await client
        .from(table)
        .select()
        .eq('user_id', userId)
        .eq('sync_status', 'synced');

    Logger.sync('PULL_ROWS', '$table: ${response.length} records');

    for (final row in response) {
      await _upsertLocal(table, row);
    }
  }

  Future<void> _upsertLocal(String table, Map<String, dynamic> data) async {
    switch (table) {
      case 'products':
        final existing = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          Logger.db('UPSERT_LOCAL', 'products', {'id': data['id']});
          await _db
              .into(_db.products)
              .insertOnConflictUpdate(Product.fromJson(data));
        } else {
          Logger.sync(
            'SKIP_CONFLICT',
            'products/${data['id']} (pending local changes)',
          );
        }
        break;
      case 'customers':
        final existing = await (_db.select(
          _db.customers,
        )..where((c) => c.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          Logger.db('UPSERT_LOCAL', 'customers', {'id': data['id']});
          final customer = Customer(
            id: data['id'] as String,
            userId: data['user_id'] as String,
            name: data['name'] as String,
            ice: data['ice'] as String?,
            rc: data['rc'] as String?,
            ifNumber: data['if_number'] as String?,
            patente: data['patente'] as String?,
            cnss: data['cnss'] as String?,
            legalForm: data['legal_form'] as String?,
            capital: data['capital'] as String?,
            status: data['status'] as String?,
            address: data['address'] as String?,
            phones: data['phones'] as String?,
            fax: data['fax'] as String?,
            emails: data['emails'] as String?,
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.customers).insertOnConflictUpdate(customer);
        } else {
          Logger.sync(
            'SKIP_CONFLICT',
            'customers/${data['id']} (pending local changes)',
          );
        }
        break;
      case 'invoices':
        final existing = await (_db.select(
          _db.invoices,
        )..where((i) => i.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          Logger.db('UPSERT_LOCAL', 'invoices', {'id': data['id']});
          final invoice = Invoice(
            id: data['id'] as String,
            userId: data['user_id'] as String,
            customerId: data['customer_id'] as String,
            type: data['type'] as String,
            number: data['number'] as String,
            status: data['status'] as String,
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
          await _db.into(_db.invoices).insertOnConflictUpdate(invoice);
        } else {
          Logger.sync(
            'SKIP_CONFLICT',
            'invoices/${data['id']} (pending local changes)',
          );
        }
        break;
      case 'invoice_items':
        final existingItem = await (_db.select(
          _db.invoiceItems,
        )..where((i) => i.id.equals(data['id']))).getSingleOrNull();

        if (existingItem == null || existingItem.syncStatus == 'synced') {
          Logger.db('UPSERT_LOCAL', 'invoice_items', {'id': data['id']});
          final item = InvoiceItem(
            id: data['id'] as String,
            invoiceId: data['invoice_id'] as String,
            productId: data['product_id'] as String?,
            productName: data['product_name'] as String?,
            description: data['description'] as String? ?? '',
            quantity: (data['quantity'] as num?)?.toDouble() ?? 1.0,
            unitPrice: (data['unit_price'] as num).toDouble(),
            tvaRate: (data['tva_rate'] as num?)?.toDouble() ?? 20.0,
            total: (data['total'] as num).toDouble(),
            syncStatus: 'synced',
          );
          await _db.into(_db.invoiceItems).insertOnConflictUpdate(item);
        } else {
          Logger.sync(
            'SKIP_CONFLICT',
            'invoice_items/${data['id']} (pending local changes)',
          );
        }
        break;
      case 'expenses':
        final existing = await (_db.select(
          _db.expenses,
        )..where((e) => e.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          Logger.db('UPSERT_LOCAL', 'expenses', {'id': data['id']});
          final expense = Expense(
            id: data['id'] as String,
            userId: data['user_id'] as String,
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
          Logger.sync(
            'SKIP_CONFLICT',
            'expenses/${data['id']} (pending local changes)',
          );
        }
        break;
      case 'owner_salaries':
        final existing = await (_db.select(
          _db.ownerSalaries,
        )..where((o) => o.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          Logger.db('UPSERT_LOCAL', 'owner_salaries', {'id': data['id']});
          final salary = OwnerSalary(
            id: data['id'] as String,
            userId: data['user_id'] as String,
            amount: (data['amount'] as num).toDouble(),
            month: data['month'] as int,
            year: data['year'] as int,
            paymentDate: data['payment_date'] != null
                ? DateTime.parse(data['payment_date'] as String)
                : null,
            createdAt: DateTime.parse(data['created_at'] as String),
            syncStatus: 'synced',
          );
          await _db.into(_db.ownerSalaries).insertOnConflictUpdate(salary);
        } else {
          Logger.sync(
            'SKIP_CONFLICT',
            'owner_salaries/${data['id']} (pending local changes)',
          );
        }
        break;
    }
  }

  Future<void> _upsertProfileLocal(Map<String, dynamic> data) async {
    final existing = await (_db.select(
      _db.profiles,
    )..where((p) => p.id.equals(data['id']))).getSingleOrNull();

    if (existing == null || existing.syncStatus == 'synced') {
      Logger.db('UPSERT_LOCAL', 'profiles', {'id': data['id']});
      final profile = Profile(
        id: data['id'] as String,
        email: data['email'] as String,
        companyName: (data['company_name'] as String?) ?? '',
        legalStatus: (data['legal_status'] as String?) ?? 'SARL',
        ice: data['ice'] as String?,
        ifNumber: data['if_number'] as String?,
        rc: data['rc'] as String?,
        cnss: data['cnss'] as String?,
        address: data['address'] as String?,
        phone: data['phone'] as String?,
        logoUrl: data['logo_url'] as String?,
        isAutoEntrepreneur: (data['is_auto_entrepreneur'] as bool?) ?? false,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: DateTime.parse(data['updated_at'] as String),
        syncStatus: 'synced',
      );
      await _db.into(_db.profiles).insertOnConflictUpdate(profile);
    } else {
      Logger.sync(
        'SKIP_CONFLICT',
        'profiles/${data['id']} (pending local changes)',
      );
    }
  }

  Future<void> _upsertPaymentLocal(Map<String, dynamic> data) async {
    final existing = await (_db.select(
      _db.payments,
    )..where((p) => p.id.equals(data['id']))).getSingleOrNull();

    if (existing == null || existing.syncStatus == 'synced') {
      Logger.db('UPSERT_LOCAL', 'payments', {'id': data['id']});
      final payment = Payment(
        id: data['id'] as String,
        invoiceId: data['invoice_id'] as String,
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
      Logger.sync(
        'SKIP_CONFLICT',
        'payments/${data['id']} (pending local changes)',
      );
    }
  }

  Stream<bool> get syncStatus =>
      Stream.periodic(const Duration(seconds: 30), (_) => true).asyncMap((
        _,
      ) async {
        Logger.sync('AUTO_SYNC_TRIGGERED');
        await syncAll();
        return true;
      });

  Stream<bool> syncStatusWithSetting(bool enabled) {
    if (!enabled) {
      Logger.sync('AUTO_SYNC_DISABLED');
      return Stream.value(false);
    }
    return syncStatus;
  }

  Future<void> queueOperation({
    required String table,
    required String operation,
    required String recordId,
    Map<String, dynamic>? data,
  }) async {
    Logger.sync('QUEUE_OP', '$operation on $table/$recordId');
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
    )..orderBy([(q) => OrderingTerm(expression: q.createdAt)])).get();
  }

  Future<void> markSynced(int queueId) async {
    Logger.db('DELETE', 'sync_queue', {'id': queueId});
    await (_db.delete(_db.syncQueue)..where((q) => q.id.equals(queueId))).go();
  }

  Future<void> incrementRetry(int queueId) async {
    final item = await (_db.select(
      _db.syncQueue,
    )..where((q) => q.id.equals(queueId))).getSingle();

    Logger.sync(
      'RETRY_INCREMENT',
      'queueId: $queueId, count: ${item.retryCount + 1}',
    );
    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(queueId))).write(
      SyncQueueCompanion(retryCount: Value(item.retryCount + 1)),
    );
  }

  Future<void> processPendingOperations({
    required Future<bool> Function(SyncQueueItem) syncHandler,
    int maxRetries = 3,
  }) async {
    final operations = await getPendingOperations();
    Logger.sync('PROCESS_QUEUE', '${operations.length} operations');

    for (final op in operations) {
      if (op.retryCount >= maxRetries) {
        Logger.sync('SKIP_MAX_RETRY', 'queueId: ${op.id}');
        continue;
      }

      try {
        final success = await syncHandler(op);
        if (success) {
          await markSynced(op.id);
        } else {
          await incrementRetry(op.id);
        }
      } catch (e, st) {
        Logger.error('PROCESS_FAILED', tag: 'SYNC', error: e, stackTrace: st);
        await incrementRetry(op.id);
      }
    }
  }

  Future<Map<String, dynamic>?> getRecord(String table, String id) async {
    switch (table) {
      case 'profiles':
        final record = await (_db.select(
          _db.profiles,
        )..where((p) => p.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'email': record.email,
          'company_name': record.companyName,
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
      case 'customers':
        final record = await (_db.select(
          _db.customers,
        )..where((c) => c.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'user_id': record.userId,
          'name': record.name,
          'ice': record.ice,
          'rc': record.rc,
          'if_number': record.ifNumber,
          'patente': record.patente,
          'cnss': record.cnss,
          'legal_form': record.legalForm,
          'capital': record.capital,
          'status': record.status,
          'address': record.address,
          'phones': record.phones,
          'fax': record.fax,
          'emails': record.emails,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };
      case 'products':
        final record = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'user_id': record.userId,
          'name': record.name,
          'description': record.description,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
        };
      case 'invoices':
        final record = await (_db.select(
          _db.invoices,
        )..where((i) => i.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'user_id': record.userId,
          'customer_id': record.customerId,
          'type': record.type,
          'number': record.number,
          'status': record.status,
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
      case 'invoice_items':
        final record = await (_db.select(
          _db.invoiceItems,
        )..where((i) => i.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'invoice_id': record.invoiceId,
          'product_id': record.productId,
          'product_name': record.productName,
          'description': record.description,
          'quantity': record.quantity,
          'unit_price': record.unitPrice,
          'tva_rate': record.tvaRate,
          'total': record.total,
        };
      case 'expenses':
        final record = await (_db.select(
          _db.expenses,
        )..where((e) => e.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'user_id': record.userId,
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
          'invoice_id': record.invoiceId,
          'amount': record.amount,
          'method': record.method,
          'payment_date': record.paymentDate.toIso8601String(),
          'check_due_date': record.checkDueDate?.toIso8601String(),
          'notes': record.notes,
          'created_at': record.createdAt.toIso8601String(),
        };
      case 'owner_salaries':
        final record = await (_db.select(
          _db.ownerSalaries,
        )..where((o) => o.id.equals(id))).getSingleOrNull();
        if (record == null) return null;
        return {
          'id': record.id,
          'user_id': record.userId,
          'amount': record.amount,
          'month': record.month,
          'year': record.year,
          'payment_date': record.paymentDate?.toIso8601String(),
          'created_at': record.createdAt.toIso8601String(),
        };
      default:
        return null;
    }
  }

  Future<void> markRecordSynced(String table, String id) async {
    final now = DateTime.now();
    Logger.db('MARK_SYNCED', table, {'id': id});

    switch (table) {
      case 'profiles':
        await (_db.update(_db.profiles)..where((p) => p.id.equals(id))).write(
          ProfilesCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'customers':
        await (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(
          CustomersCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
        );
        break;
      case 'invoices':
        await (_db.update(_db.invoices)..where((i) => i.id.equals(id))).write(
          InvoicesCompanion(
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
      case 'products':
        await (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
          ProductsCompanion(
            syncStatus: const Value('synced'),
            updatedAt: Value(now),
          ),
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
    Logger.db('UPDATE_RECEIPT_URLS', 'expenses', {
      'id': expenseId,
      'url': remoteUrl,
      'local': localPath,
    });
  }

  Future<int> getPendingCount() async {
    final items = await (_db.select(_db.syncQueue)).get();
    return items.length;
  }

  Future<void> clearQueue() async {
    Logger.sync('CLEAR_QUEUE');
    await (_db.delete(_db.syncQueue)).go();
  }
}
