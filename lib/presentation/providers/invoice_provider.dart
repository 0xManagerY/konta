import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/invoice_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return InvoiceRepository(db, syncQueue);
});

final invoicesProvider = StreamProvider<List<Invoice>>((ref) {
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) return Stream.value([]);

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
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) return Stream.value([]);

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
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) return Stream.value([]);

  return (db.select(db.invoices)
        ..where((i) => i.userId.equals(userId) & i.status.equals(status))
        ..orderBy([
          (i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();
});
