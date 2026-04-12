import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/product_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return ProductRepository(db, syncQueue);
});

final productsProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) return Stream.value([]);

  return (db.select(db.products)
        ..where((p) => p.userId.equals(userId))
        ..orderBy([(p) => OrderingTerm(expression: p.name)]))
      .watch();
});

final productByIdProvider = StreamProvider.family<Product?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.products,
  )..where((p) => p.id.equals(id))).watchSingleOrNull();
});
