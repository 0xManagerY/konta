import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class PaymentRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;

  PaymentRepository(this._db, this._syncQueue);

  Future<List<Payment>> getAll() async {
    Logger.method('PaymentRepository', 'getAll');
    return (_db.select(_db.payments)..orderBy([
          (p) =>
              OrderingTerm(expression: p.paymentDate, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<Payment?> getById(String id) async {
    Logger.method('PaymentRepository', 'getById', {'id': id});
    return (_db.select(
      _db.payments,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<List<Payment>> getByInvoice(String invoiceId) async {
    Logger.method('PaymentRepository', 'getByInvoice', {
      'invoiceId': invoiceId,
    });
    return (_db.select(_db.payments)
          ..where((p) => p.invoiceId.equals(invoiceId))
          ..orderBy([
            (p) => OrderingTerm(
              expression: p.paymentDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<String> create({
    required String invoiceId,
    required double amount,
    required String method,
    required DateTime paymentDate,
    DateTime? checkDueDate,
    String? notes,
  }) async {
    Logger.method('PaymentRepository', 'create', {
      'invoiceId': invoiceId,
      'amount': amount,
      'method': method,
    });
    final id = const Uuid().v4();
    final now = DateTime.now();

    Logger.db('INSERT', 'payments', {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
    });
    await _db
        .into(_db.payments)
        .insert(
          PaymentsCompanion(
            id: Value(id),
            invoiceId: Value(invoiceId),
            amount: Value(amount),
            method: Value(method),
            paymentDate: Value(paymentDate),
            checkDueDate: Value(checkDueDate),
            notes: Value(notes),
            createdAt: Value(now),
            syncStatus: const Value('pending'),
          ),
        );

    await _syncQueue.queueInsert('payments', id);
    Logger.success('Payment created: $id', tag: 'REPO');
    return id;
  }

  Future<void> update(Payment payment) async {
    Logger.method('PaymentRepository', 'update', {'id': payment.id});
    Logger.db('UPDATE', 'payments', {'id': payment.id});
    await (_db.update(
      _db.payments,
    )..where((p) => p.id.equals(payment.id))).write(
      PaymentsCompanion(
        amount: Value(payment.amount),
        method: Value(payment.method),
        paymentDate: Value(payment.paymentDate),
        checkDueDate: Value(payment.checkDueDate),
        notes: Value(payment.notes),
        syncStatus: const Value('pending'),
      ),
    );
    await _syncQueue.queueUpdate('payments', payment.id);
    Logger.success('Payment updated', tag: 'REPO');
  }

  Future<void> delete(String id) async {
    Logger.method('PaymentRepository', 'delete', {'id': id});
    Logger.db('DELETE', 'payments', {'id': id});
    await _syncQueue.queueDelete('payments', id);
    await (_db.delete(_db.payments)..where((p) => p.id.equals(id))).go();
    Logger.success('Payment deleted', tag: 'REPO');
  }

  Future<double> getTotalPaidForInvoice(String invoiceId) async {
    final payments = await getByInvoice(invoiceId);
    final total = payments.fold<double>(0.0, (sum, p) => sum + p.amount);
    Logger.debug('Total paid for invoice $invoiceId: $total', tag: 'REPO');
    return total;
  }

  Future<List<Payment>> getCheckReminders() async {
    Logger.method('PaymentRepository', 'getCheckReminders');
    final now = DateTime.now();
    return (_db.select(_db.payments)
          ..where(
            (p) =>
                p.method.equals('check') &
                p.checkDueDate.isNotNull() &
                p.checkDueDate.isBiggerOrEqualValue(now),
          )
          ..orderBy([(p) => OrderingTerm(expression: p.checkDueDate)]))
        .get();
  }

  Future<List<Payment>> getOverdueChecks() async {
    Logger.method('PaymentRepository', 'getOverdueChecks');
    final now = DateTime.now();
    return (_db.select(_db.payments)
          ..where(
            (p) =>
                p.method.equals('check') &
                p.checkDueDate.isNotNull() &
                p.checkDueDate.isSmallerThanValue(now),
          )
          ..orderBy([(p) => OrderingTerm(expression: p.checkDueDate)]))
        .get();
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    Logger.debug('Generated ID: $id', tag: 'REPO');
    return id;
  }
}
