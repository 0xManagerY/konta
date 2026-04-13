import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/invoice_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  Logger.method('Provider', 'invoiceRepositoryProvider', {'init': true});
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return InvoiceRepository(db, syncQueue);
});

final invoicesProvider = StreamProvider<List<Invoice>>((ref) {
  Logger.method('Provider', 'invoicesProvider', {'watch': true});
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) {
    Logger.warning(
      'No user ID, returning empty invoices stream',
      tag: 'INVOICE_PROVIDER',
    );
    return Stream.value([]);
  }

  Logger.debug('Watching invoices for user: $userId', tag: 'INVOICE_PROVIDER');
  return (db.select(db.invoices)
        ..where((i) => i.userId.equals(userId))
        ..orderBy([
          (i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();
});

final invoicesByTypeProvider = StreamProvider.family<List<Invoice>, String>((
  ref,
  type,
) {
  Logger.method('Provider', 'invoicesByTypeProvider', {'type': type});
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) {
    Logger.warning(
      'No user ID, returning empty invoices stream',
      tag: 'INVOICE_PROVIDER',
    );
    return Stream.value([]);
  }

  Logger.debug(
    'Watching invoices type=$type for user: $userId',
    tag: 'INVOICE_PROVIDER',
  );
  return (db.select(db.invoices)
        ..where((i) => i.userId.equals(userId) & i.type.equals(type))
        ..orderBy([
          (i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();
});

final invoicesByStatusProvider = StreamProvider.family<List<Invoice>, String>((
  ref,
  status,
) {
  Logger.method('Provider', 'invoicesByStatusProvider', {'status': status});
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) {
    Logger.warning(
      'No user ID, returning empty invoices stream',
      tag: 'INVOICE_PROVIDER',
    );
    return Stream.value([]);
  }

  Logger.debug(
    'Watching invoices status=$status for user: $userId',
    tag: 'INVOICE_PROVIDER',
  );
  return (db.select(db.invoices)
        ..where((i) => i.userId.equals(userId) & i.status.equals(status))
        ..orderBy([
          (i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();
});
