import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/payment_repository.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/domain/services/log_service.dart';

final _log = LogService();

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  _log.debug('Provider', 'paymentRepositoryProvider', data: {'init': true});
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return PaymentRepository(db, syncQueue);
});

final paymentsForInvoiceProvider = StreamProvider.family<List<Payment>, String>(
  (ref, invoiceId) {
    _log.debug(
      'Provider',
      'paymentsForInvoiceProvider',
      data: {'invoiceId': invoiceId},
    );
    final db = ref.watch(databaseProvider);

    _log.debug('Provider', 'Watching payments for invoice: $invoiceId');
    return (db.select(db.payments)
          ..where((p) => p.documentId.equals(invoiceId))
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
  _log.debug('Provider', 'checkRemindersProvider', data: {'watch': true});
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  _log.debug('Provider', 'Watching check reminders from: $now');
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
  _log.debug('Provider', 'overdueChecksProvider', data: {'watch': true});
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  _log.debug('Provider', 'Watching overdue checks before: $now');
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
