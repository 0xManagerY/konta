import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/payment_repository.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return PaymentRepository(db, syncQueue);
});

final paymentsForInvoiceProvider = StreamProvider.family<List<Payment>, String>(
  (ref, invoiceId) {
    final db = ref.watch(databaseProvider);

    return (db.select(db.payments)
          ..where((p) => p.invoiceId.equals(invoiceId))
          ..orderBy([
            (p) => OrderingTerm(
              expression: p.paymentDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  },
);

final checkRemindersProvider = StreamProvider<List<Payment>>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  return (db.select(db.payments)
        ..where(
          (p) =>
              p.method.equals('check') &
              p.checkDueDate.isNotNull() &
              p.checkDueDate.isBiggerOrEqualValue(now),
        )
        ..orderBy([(p) => OrderingTerm(expression: p.checkDueDate)]))
      .watch();
});

final overdueChecksProvider = StreamProvider<List<Payment>>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  return (db.select(db.payments)
        ..where(
          (p) =>
              p.method.equals('check') &
              p.checkDueDate.isNotNull() &
              p.checkDueDate.isSmallerThanValue(now),
        )
        ..orderBy([(p) => OrderingTerm(expression: p.checkDueDate)]))
      .watch();
});
