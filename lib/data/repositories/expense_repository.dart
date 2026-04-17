import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class ExpenseRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  ExpenseRepository(this._db, this._syncQueue);

  Future<List<Expense>> getAll(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getAll - fetching expenses',
      data: {'companyId': companyId},
    );
    try {
      final result = await _db.getExpensesByCompany(companyId);
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

  Future<Expense?> getById(String id) async {
    _log.debug(LogTags.repo, 'getById - fetching expense', data: {'id': id});
    try {
      final query = _db.select(_db.expenses)..where((e) => e.id.equals(id));
      final result = await query.getSingleOrNull();
      final found = result != null;
      _log.info(LogTags.repo, 'getById - completed', data: {'found': found});
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getById - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> insert(Expense expense) async {
    _log.debug(LogTags.repo, 'insert - starting', data: {'id': expense.id});
    try {
      await _db.into(_db.expenses).insert(expense);
      await _syncQueue.queueInsert('expenses', expense.id);
      _log.info(LogTags.repo, 'insert - completed', data: {'id': expense.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'insert - failed',
        error: e,
        stack: st,
        data: {'id': expense.id},
      );
      rethrow;
    }
  }

  Future<String> create({
    required String companyId,
    required String category,
    required double amount,
    required DateTime date,
    double tvaAmount = 0,
    String? description,
    String? receiptUrl,
    String? receiptLocalPath,
    bool isDeductible = true,
  }) async {
    _log.debug(
      LogTags.repo,
      'create - starting',
      data: {'companyId': companyId, 'amount': amount},
    );
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final expense = Expense(
        id: id,
        companyId: companyId,
        category: category,
        amount: amount,
        tvaAmount: tvaAmount,
        date: date,
        description: description,
        receiptUrl: receiptUrl,
        receiptLocalPath: receiptLocalPath,
        isDeductible: isDeductible,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      await _db.into(_db.expenses).insert(expense);
      await _syncQueue.queueInsert('expenses', id);
      _log.info(LogTags.repo, 'create - completed', data: {'id': id});
      return id;
    } catch (e, st) {
      _log.error(LogTags.repo, 'create - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> update(Expense expense) async {
    _log.debug(LogTags.repo, 'update - starting', data: {'id': expense.id});
    try {
      await (_db.update(
        _db.expenses,
      )..where((e) => e.id.equals(expense.id))).write(
        ExpensesCompanion(
          category: Value(expense.category),
          amount: Value(expense.amount),
          tvaAmount: Value(expense.tvaAmount),
          date: Value(expense.date),
          description: Value(expense.description),
          receiptUrl: Value(expense.receiptUrl),
          receiptLocalPath: Value(expense.receiptLocalPath),
          isDeductible: Value(expense.isDeductible),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
      await _syncQueue.queueUpdate('expenses', expense.id);
      _log.info(LogTags.repo, 'update - completed', data: {'id': expense.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'update - failed',
        error: e,
        stack: st,
        data: {'id': expense.id},
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    try {
      await _syncQueue.queueDelete('expenses', id);
      await (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();
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

  Future<List<Expense>> getByMonth(
    String companyId,
    int year,
    int month,
  ) async {
    _log.debug(
      LogTags.repo,
      'getByMonth - fetching expenses',
      data: {'companyId': companyId, 'year': year, 'month': month},
    );
    try {
      final result = await _db.getExpensesByMonth(companyId, year, month);
      _log.info(
        LogTags.repo,
        'getByMonth - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByMonth - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<List<Expense>> getByCategory(String companyId, String category) async {
    _log.debug(
      LogTags.repo,
      'getByCategory - fetching expenses',
      data: {'companyId': companyId, 'category': category},
    );
    try {
      final result =
          (_db.select(_db.expenses)
                ..where(
                  (e) =>
                      e.companyId.equals(companyId) &
                      e.category.equals(category),
                )
                ..orderBy([(e) => OrderingTerm.desc(e.date)]))
              .get();
      _log.info(LogTags.repo, 'getByCategory - completed');
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByCategory - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<double> getTotalByMonth(String companyId, int year, int month) async {
    return _db.getTotalExpensesByMonth(companyId, year, month);
  }

  Future<double> getDeductibleTotalByMonth(
    String companyId,
    int year,
    int month,
  ) async {
    final expenses = await getByMonth(companyId, year, month);
    final total = expenses
        .where((e) => e.isDeductible)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    _log.debug(
      LogTags.repo,
      'getDeductibleTotalByMonth - result',
      data: {'total': total},
    );
    return total;
  }

  Future<Map<String, double>> getTotalsByCategory(
    String companyId,
    int year,
    int month,
  ) async {
    final expenses = await getByMonth(companyId, year, month);
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    _log.debug(
      LogTags.repo,
      'getTotalsByCategory - result',
      data: {'categories': map.length},
    );
    return map;
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    _log.debug(LogTags.repo, 'generateId - generated', data: {'id': id});
    return id;
  }
}
