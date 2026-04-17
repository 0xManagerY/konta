import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/product_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

final productRepositoryProvider = Provider<ItemRepository>((ref) {
  Logger.method('Provider', 'productRepositoryProvider', {'init': true});
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return ItemRepository(db, syncQueue);
});

final productsProvider = StreamProvider<List<Item>>((ref) {
  Logger.method('Provider', 'productsProvider', {'watch': true});
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) {
    Logger.warning(
      'No user ID, returning empty products stream',
      tag: 'PRODUCT_PROVIDER',
    );
    return Stream.value([]);
  }

  Logger.debug('Watching products for user: $userId', tag: 'PRODUCT_PROVIDER');
  return (db.select(db.items)
        ..where((p) => p.companyId.equals(userId))
        ..orderBy([(p) => OrderingTerm(expression: p.name)]))
      .watch();
});

final productByIdProvider = StreamProvider.family<Item?, String>((ref, id) {
  Logger.method('Provider', 'productByIdProvider', {'id': id});
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.items,
  )..where((p) => p.id.equals(id))).watchSingleOrNull();
});
