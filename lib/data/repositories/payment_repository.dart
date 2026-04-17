import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class PaymentRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  PaymentRepository(this._db, this._syncQueue);

  Future<List<Payment>> getAll(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getAll - fetching payments',
      data: {'companyId': companyId},
    );
    try {
      final result = await _db.getPaymentsByCompany(companyId);
      _log.info(
        LogTags.repo,
        'getAll - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getAll - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<Payment?> getById(String id) async {
    _log.debug(LogTags.repo, 'getById - fetching payment', data: {'id': id});
    try {
      final query = _db.select(_db.payments)..where((p) => p.id.equals(id));
      final result = await query.getSingleOrNull();
      final found = result != null;
      _log.info(LogTags.repo, 'getById - completed', data: {'found': found});
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getById - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<List<Payment>> getByDocument(String documentId) async {
    _log.debug(
      LogTags.repo,
      'getByDocument - fetching payments',
      data: {'documentId': documentId},
    );
    try {
      final result = await _db.getPaymentsByDocument(documentId);
      _log.info(
        LogTags.repo,
        'getByDocument - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByDocument - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<String> create({
    required String companyId,
    required String documentId,
    required double amount,
    required String method,
    required DateTime paymentDate,
    DateTime? checkDueDate,
    String? notes,
  }) async {
    _log.debug(
      LogTags.repo,
      'create - starting',
      data: {
        'companyId': companyId,
        'documentId': documentId,
        'amount': amount,
        'method': method,
      },
    );
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      await _db
          .into(_db.payments)
          .insert(
            Payment(
              id: id,
              companyId: companyId,
              documentId: documentId,
              amount: amount,
              method: method,
              paymentDate: paymentDate,
              checkDueDate: checkDueDate,
              notes: notes,
              createdAt: now,
              syncStatus: 'pending',
            ),
          );

      await _syncQueue.queueInsert('payments', id);
      _log.info(LogTags.repo, 'create - completed', data: {'id': id});
      return id;
    } catch (e, st) {
      _log.error(LogTags.repo, 'create - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> update(Payment payment) async {
    _log.debug(LogTags.repo, 'update - starting', data: {'id': payment.id});
    try {
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
      _log.info(LogTags.repo, 'update - completed', data: {'id': payment.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'update - failed',
        error: e,
        stack: st,
        data: {'id': payment.id},
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    try {
      await _syncQueue.queueDelete('payments', id);
      await (_db.delete(_db.payments)..where((p) => p.id.equals(id))).go();
      _log.info(LogTags.repo, 'delete - completed', data: {'id': id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'delete - failed',
        error: e,
        stack: st,
        data: {'id': id},
      );
      rethrow;
    }
  }

  Future<double> getTotalPaidForDocument(String documentId) async {
    return _db.getTotalPaidForDocument(documentId);
  }

  Future<List<Payment>> getPendingChecks() async {
    return _db.getPendingChecks();
  }

  Future<List<Payment>> getOverdueChecks() async {
    return _db.getOverdueChecks();
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    _log.debug(LogTags.repo, 'generateId - generated', data: {'id': id});
    return id;
  }
}
