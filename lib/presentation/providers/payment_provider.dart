import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/payment_repository.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  Logger.method('Provider', 'paymentRepositoryProvider', {'init': true});
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return PaymentRepository(db, syncQueue);
});

final paymentsForInvoiceProvider = StreamProvider.family<List<Payment>, String>(
  (ref, invoiceId) {
    Logger.method('Provider', 'paymentsForInvoiceProvider', {
      'invoiceId': invoiceId,
    });
    final db = ref.watch(databaseProvider);

    Logger.debug(
      'Watching payments for invoice: $invoiceId',
      tag: 'PAYMENT_PROVIDER',
    );
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
  Logger.method('Provider', 'checkRemindersProvider', {'watch': true});
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  Logger.debug('Watching check reminders from: $now', tag: 'PAYMENT_PROVIDER');
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
  Logger.method('Provider', 'overdueChecksProvider', {'watch': true});
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  Logger.debug('Watching overdue checks before: $now', tag: 'PAYMENT_PROVIDER');
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
