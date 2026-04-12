import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/expense_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepository(db);
});

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) return Stream.value([]);

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
      final db = ref.watch(databaseProvider);
      final userId = SupabaseService.currentUserId;
      if (userId == null) return Stream.value([]);

      final start = DateTime(params.year, params.month, 1);
      final end = DateTime(params.year, params.month + 1, 0, 23, 59, 59);

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
      final repo = ref.watch(expenseRepositoryProvider);
      final userId = SupabaseService.currentUserId;
      if (userId == null) return {};

      return repo.getTotalsByCategory(userId, params.year, params.month);
    });
