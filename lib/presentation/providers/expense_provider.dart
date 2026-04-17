import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/expense_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/domain/services/log_service.dart';

final _log = LogService();

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  _log.debug('Provider', 'expenseRepositoryProvider', data: {'init': true});
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return ExpenseRepository(db, syncQueue);
});

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  _log.debug('Provider', 'expensesProvider', data: {'watch': true});
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) {
    _log.warn('Provider', 'No user ID, returning empty expenses stream');
    return Stream.value([]);
  }

  _log.debug('Provider', 'Watching expenses for user: $userId');
  return (db.select(db.expenses)
        ..where((e) => e.companyId.equals(userId))
        ..orderBy([
          (e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc),
        ]))
      .watch();
});

final expensesByMonthProvider =
    StreamProvider.family<List<Expense>, ({int year, int month})>((
      ref,
      params,
    ) {
      _log.debug(
        'Provider',
        'expensesByMonthProvider',
        data: {'year': params.year, 'month': params.month},
      );
      final db = ref.watch(databaseProvider);
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        _log.warn('Provider', 'No user ID, returning empty expenses stream');
        return Stream.value([]);
      }

      final start = DateTime(params.year, params.month, 1);
      final end = DateTime(params.year, params.month + 1, 0, 23, 59, 59);
      _log.debug('Provider', 'Watching expenses from $start to $end');

      return (db.select(db.expenses)
            ..where(
              (e) =>
                  e.companyId.equals(userId) &
                  e.date.isBiggerOrEqualValue(start) &
                  e.date.isSmallerOrEqualValue(end),
            )
            ..orderBy([
              (e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc),
            ]))
          .watch();
    });

final expenseTotalsProvider =
    FutureProvider.family<Map<String, double>, ({int year, int month})>((
      ref,
      params,
    ) async {
      _log.debug(
        'Provider',
        'expenseTotalsProvider',
        data: {'year': params.year, 'month': params.month},
      );
      final repo = ref.watch(expenseRepositoryProvider);
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        _log.warn('Provider', 'No user ID, returning empty totals');
        return {};
      }

      final totals = await repo.getTotalsByCategory(
        userId,
        params.year,
        params.month,
      );
      _log.debug('Provider', 'Expense totals: $totals');
      return totals;
    });
