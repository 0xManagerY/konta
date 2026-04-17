import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class ItemRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;

  ItemRepository(this._db, this._syncQueue);

  Future<List<Item>> getAll(String companyId) async {
    Logger.method('ProductRepository', 'getAll', {'companyId': companyId});
    return (_db.select(_db.items)
          ..where((p) => p.companyId.equals(companyId))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  Future<Item?> getById(String id) async {
    Logger.method('ProductRepository', 'getById', {'id': id});
    return (_db.select(
      _db.items,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<List<Item>> search(String companyId, String query) async {
    Logger.method('ProductRepository', 'search', {
      'companyId': companyId,
      'query': query,
    });
    final lowerQuery = query.toLowerCase();
    return (_db.select(_db.items)
          ..where(
            (p) =>
                p.companyId.equals(companyId) &
                p.name.lower().contains(lowerQuery),
          )
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  Future<String> insert(ItemsCompanion product) async {
    Logger.method('ProductRepository', 'insert', {'name': product.name.value});
    final id = const Uuid().v4();
    await _db
        .into(_db.items)
        .insert(
          product.copyWith(
            id: Value(id),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending'),
          ),
        );
    await _syncQueue.queueInsert('products', id);
    Logger.success('Product inserted', tag: 'REPO');
    return id;
  }

  Future<void> update(Item product) async {
    Logger.method('ProductRepository', 'update', {'id': product.id});
    await (_db.update(_db.items)).replace(
      product.copyWith(updatedAt: DateTime.now(), syncStatus: 'pending'),
    );
    await _syncQueue.queueUpdate('products', product.id);
    Logger.success('Product updated', tag: 'REPO');
  }

  Future<void> delete(String id) async {
    Logger.method('ProductRepository', 'delete', {'id': id});
    await _syncQueue.queueDelete('products', id);
    await (_db.delete(_db.items)..where((p) => p.id.equals(id))).go();
    Logger.success('Product deleted', tag: 'REPO');
  }

  Future<bool> isUsedInInvoices(String productId) async {
    Logger.method('ProductRepository', 'isUsedInInvoices', {
      'productId': productId,
    });
    final count =
        await (_db.select(_db.documentLines)
              ..where((i) => i.itemId.equals(productId)))
            .get()
            .then((list) => list.length);
    return count > 0;
  }
}
