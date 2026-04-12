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
      case 'customers':
        if (op.operation == 'delete') {
          Logger.network('DELETE', 'customers/${op.recordId}');
          await client.from('customers').delete().eq('id', op.recordId);
        } else {
          Logger.network('UPSERT', 'customers', data);
          await client.from('customers').upsert(data, onConflict: 'id');
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

    Logger.sync('PULL_TABLE', 'customers');
    await _pullTable('customers', userId, client);
    Logger.sync('PULL_TABLE', 'invoices');
    await _pullTable('invoices', userId, client);
    Logger.sync('PULL_TABLE', 'expenses');
    await _pullTable('expenses', userId, client);
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
      case 'customers':
        final existing = await (_db.select(
          _db.customers,
        )..where((c) => c.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          Logger.db('UPSERT_LOCAL', 'customers', {'id': data['id']});
          await _db
              .into(_db.customers)
              .insertOnConflictUpdate(Customer.fromJson(data));
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
          await _db
              .into(_db.invoices)
              .insertOnConflictUpdate(Invoice.fromJson(data));
        } else {
          Logger.sync(
            'SKIP_CONFLICT',
            'invoices/${data['id']} (pending local changes)',
          );
        }
        break;
      case 'expenses':
        final existing = await (_db.select(
          _db.expenses,
        )..where((e) => e.id.equals(data['id']))).getSingleOrNull();

        if (existing == null || existing.syncStatus == 'synced') {
          Logger.db('UPSERT_LOCAL', 'expenses', {'id': data['id']});
          await _db
              .into(_db.expenses)
              .insertOnConflictUpdate(Expense.fromJson(data));
        } else {
          Logger.sync(
            'SKIP_CONFLICT',
            'expenses/${data['id']} (pending local changes)',
          );
        }
        break;
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
          'address': record.address,
          'phones': record.phones,
          'emails': record.emails,
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
          'is_converted': record.isConverted,
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
      default:
        return null;
    }
  }

  Future<void> markRecordSynced(String table, String id) async {
    final now = DateTime.now();
    Logger.db('MARK_SYNCED', table, {'id': id});

    switch (table) {
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
            updatedAt: Value(DateTime.now()),
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
