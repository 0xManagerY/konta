import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/expense_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  Logger.method('Provider', 'expenseRepositoryProvider', {'init': true});
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return ExpenseRepository(db, syncQueue);
});

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  Logger.method('Provider', 'expensesProvider', {'watch': true});
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) {
    Logger.warning(
      'No user ID, returning empty expenses stream',
      tag: 'EXPENSE_PROVIDER',
    );
    return Stream.value([]);
  }

  Logger.debug('Watching expenses for user: $userId', tag: 'EXPENSE_PROVIDER');
  return (db.select(db.expenses)
        ..where((e) => e.userId.equals(userId))
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
      Logger.method('Provider', 'expensesByMonthProvider', {
        'year': params.year,
        'month': params.month,
      });
      final db = ref.watch(databaseProvider);
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        Logger.warning(
          'No user ID, returning empty expenses stream',
          tag: 'EXPENSE_PROVIDER',
        );
        return Stream.value([]);
      }

      final start = DateTime(params.year, params.month, 1);
      final end = DateTime(params.year, params.month + 1, 0, 23, 59, 59);
      Logger.debug(
        'Watching expenses from $start to $end',
        tag: 'EXPENSE_PROVIDER',
      );

      return (db.select(db.expenses)
            ..where(
              (e) =>
                  e.userId.equals(userId) &
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
      Logger.method('Provider', 'expenseTotalsProvider', {
        'year': params.year,
        'month': params.month,
      });
      final repo = ref.watch(expenseRepositoryProvider);
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        Logger.warning(
          'No user ID, returning empty totals',
          tag: 'EXPENSE_PROVIDER',
        );
        return {};
      }

      final totals = await repo.getTotalsByCategory(
        userId,
        params.year,
        params.month,
      );
      Logger.debug('Expense totals: $totals', tag: 'EXPENSE_PROVIDER');
      return totals;
    });
