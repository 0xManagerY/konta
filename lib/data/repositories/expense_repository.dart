import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class ExpenseRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;

  ExpenseRepository(this._db, this._syncQueue);

  Future<List<Expense>> getAll(String userId) async {
    Logger.method('ExpenseRepository', 'getAll', {'userId': userId});
    return (_db.select(_db.expenses)
          ..where((e) => e.userId.equals(userId))
          ..orderBy([
            (e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<Expense?> getById(String id) async {
    Logger.method('ExpenseRepository', 'getById', {'id': id});
    return (_db.select(
      _db.expenses,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<void> insert(Expense expense) async {
    Logger.method('ExpenseRepository', 'insert', {'id': expense.id});
    Logger.db('INSERT', 'expenses', {
      'id': expense.id,
      'amount': expense.amount,
    });
    await _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion(
            id: Value(expense.id),
            userId: Value(expense.userId),
            category: Value(expense.category),
            amount: Value(expense.amount),
            tvaAmount: Value(expense.tvaAmount),
            date: Value(expense.date),
            description: Value(expense.description),
            receiptUrl: Value(expense.receiptUrl),
            receiptLocalPath: Value(expense.receiptLocalPath),
            isDeductible: Value(expense.isDeductible),
            createdAt: Value(expense.createdAt),
            updatedAt: Value(expense.updatedAt),
            syncStatus: const Value('pending'),
          ),
        );
    await _syncQueue.queueInsert('expenses', expense.id);
    Logger.success('Expense inserted', tag: 'REPO');
  }

  Future<String> create({
    required String userId,
    required String category,
    required double amount,
    required DateTime date,
    double tvaAmount = 0,
    String? description,
    String? receiptUrl,
    String? receiptLocalPath,
    bool isDeductible = true,
  }) async {
    Logger.method('ExpenseRepository', 'create', {
      'userId': userId,
      'amount': amount,
    });
    final id = const Uuid().v4();
    final now = DateTime.now();

    Logger.db('INSERT', 'expenses', {
      'id': id,
      'category': category,
      'amount': amount,
    });
    await _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion(
            id: Value(id),
            userId: Value(userId),
            category: Value(category),
            amount: Value(amount),
            tvaAmount: Value(tvaAmount),
            date: Value(date),
            description: Value(description),
            receiptUrl: Value(receiptUrl),
            receiptLocalPath: Value(receiptLocalPath),
            isDeductible: Value(isDeductible),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value('pending'),
          ),
        );

    Logger.success('Expense created: $id', tag: 'REPO');
    await _syncQueue.queueInsert('expenses', id);
    return id;
  }

  Future<void> update(Expense expense) async {
    Logger.method('ExpenseRepository', 'update', {'id': expense.id});
    Logger.db('UPDATE', 'expenses', {'id': expense.id});
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
    Logger.success('Expense updated', tag: 'REPO');
  }

  Future<void> delete(String id) async {
    Logger.method('ExpenseRepository', 'delete', {'id': id});
    Logger.db('DELETE', 'expenses', {'id': id});
    await _syncQueue.queueDelete('expenses', id);
    await (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();
    Logger.success('Expense deleted', tag: 'REPO');
  }

  Future<List<Expense>> getByMonth(String userId, int year, int month) async {
    Logger.method('ExpenseRepository', 'getByMonth', {
      'userId': userId,
      'year': year,
      'month': month,
    });
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    return (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.userId.equals(userId) &
                e.date.isBiggerOrEqualValue(start) &
                e.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([
            (e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<List<Expense>> getByCategory(String userId, String category) async {
    Logger.method('ExpenseRepository', 'getByCategory', {
      'userId': userId,
      'category': category,
    });
    return (_db.select(_db.expenses)
          ..where((e) => e.userId.equals(userId) & e.category.equals(category))
          ..orderBy([
            (e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<double> getTotalByMonth(String userId, int year, int month) async {
    final expenses = await getByMonth(userId, year, month);
    final total = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    Logger.debug('Total by month: $total', tag: 'REPO');
    return total;
  }

  Future<double> getDeductibleTotalByMonth(
    String userId,
    int year,
    int month,
  ) async {
    final expenses = await getByMonth(userId, year, month);
    final total = expenses
        .where((e) => e.isDeductible)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    Logger.debug('Deductible total by month: $total', tag: 'REPO');
    return total;
  }

  Future<Map<String, double>> getTotalsByCategory(
    String userId,
    int year,
    int month,
  ) async {
    final expenses = await getByMonth(userId, year, month);
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    Logger.debug('Totals by category: $map', tag: 'REPO');
    return map;
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    Logger.debug('Generated ID: $id', tag: 'REPO');
    return id;
  }
}
