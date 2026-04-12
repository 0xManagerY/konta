import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';

class ProductRepository {
  final AppDatabase _db;

  ProductRepository(this._db);

  Future<List<Product>> getAll(String userId) async {
    Logger.method('ProductRepository', 'getAll', {'userId': userId});
    return (_db.select(_db.products)
          ..where((p) => p.userId.equals(userId))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  Future<Product?> getById(String id) async {
    Logger.method('ProductRepository', 'getById', {'id': id});
    return (_db.select(
      _db.products,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<List<Product>> search(String userId, String query) async {
    Logger.method('ProductRepository', 'search', {
      'userId': userId,
      'query': query,
    });
    final lowerQuery = query.toLowerCase();
    return (_db.select(_db.products)
          ..where(
            (p) =>
                p.userId.equals(userId) & p.name.lower().contains(lowerQuery),
          )
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  Future<String> insert(ProductsCompanion product) async {
    Logger.method('ProductRepository', 'insert', {'name': product.name.value});
    final id = const Uuid().v4();
    await _db
        .into(_db.products)
        .insert(
          product.copyWith(
            id: Value(id),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending'),
          ),
        );
    Logger.success('Product inserted', tag: 'REPO');
    return id;
  }

  Future<void> update(Product product) async {
    Logger.method('ProductRepository', 'update', {'id': product.id});
    await (_db.update(_db.products)).replace(
      product.copyWith(updatedAt: DateTime.now(), syncStatus: 'pending'),
    );
    Logger.success('Product updated', tag: 'REPO');
  }

  Future<void> delete(String id) async {
    Logger.method('ProductRepository', 'delete', {'id': id});
    await (_db.delete(_db.products)..where((p) => p.id.equals(id))).go();
    Logger.success('Product deleted', tag: 'REPO');
  }

  Future<bool> isUsedInInvoices(String productId) async {
    Logger.method('ProductRepository', 'isUsedInInvoices', {
      'productId': productId,
    });
    final count =
        await (_db.select(_db.invoiceItems)
              ..where((i) => i.productId.equals(productId)))
            .get()
            .then((list) => list.length);
    return count > 0;
  }
}
