import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class ItemRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  ItemRepository(this._db, this._syncQueue);

  Future<List<Item>> getAll(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getAll - fetching items',
      data: {'companyId': companyId},
    );
    try {
      final result = await _db.getItemsByCompany(companyId);
      _log.info(
        LogTags.repo,
        'getAll - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getAll - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<List<Item>> getByCategory(String companyId, String category) async {
    _log.debug(
      LogTags.repo,
      'getByCategory - fetching items',
      data: {'companyId': companyId, 'category': category},
    );
    try {
      final result = await _db.getItemsByCategory(companyId, category);
      _log.info(
        LogTags.repo,
        'getByCategory - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByCategory - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<Item?> getById(String id) async {
    _log.debug(LogTags.repo, 'getById - fetching item', data: {'id': id});
    try {
      final result = await _db.getItemById(id);
      _log.info(
        LogTags.repo,
        'getById - completed',
        data: {'found': result != null},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getById - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> insert(Item item) async {
    _log.debug(
      LogTags.repo,
      'insert - starting',
      data: {'id': item.id, 'name': item.name},
    );
    try {
      await _db.into(_db.items).insert(item);
      await _syncQueue.queueInsert('items', item.id);
      _log.info(LogTags.repo, 'insert - completed', data: {'id': item.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'insert - failed',
        error: e,
        stack: st,
        data: {'id': item.id},
      );
      rethrow;
    }
  }

  Future<void> update(Item item) async {
    _log.debug(LogTags.repo, 'update - starting', data: {'id': item.id});
    try {
      await (_db.update(_db.items)..where((i) => i.id.equals(item.id))).write(
        ItemsCompanion(
          name: Value(item.name),
          description: Value(item.description),
          defaultUnitPrice: Value(item.defaultUnitPrice),
          defaultTaxId: Value(item.defaultTaxId),
          category: Value(item.category),
          isActive: Value(item.isActive),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
      await _syncQueue.queueUpdate('items', item.id);
      _log.info(LogTags.repo, 'update - completed', data: {'id': item.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'update - failed',
        error: e,
        stack: st,
        data: {'id': item.id},
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    try {
      await _syncQueue.queueDelete('items', id);
      await (_db.delete(_db.items)..where((i) => i.id.equals(id))).go();
      _log.info(LogTags.repo, 'delete - completed', data: {'id': id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'delete - failed',
        error: e,
        stack: st,
        data: {'id': id},
      );
      rethrow;
    }
  }

  Future<List<Item>> search(String companyId, String query) async {
    _log.debug(
      LogTags.repo,
      'search - starting',
      data: {'companyId': companyId, 'query': query},
    );
    try {
      final searchPattern = '%$query%';
      final result =
          (_db.select(_db.items)
                ..where(
                  (i) =>
                      i.companyId.equals(companyId) &
                      i.isActive.equals(true) &
                      (i.name.like(searchPattern) |
                          i.description.like(searchPattern)),
                )
                ..orderBy([(i) => OrderingTerm.asc(i.name)]))
              .get();
      _log.info(LogTags.repo, 'search - completed', data: {'query': query});
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'search - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    _log.debug(LogTags.repo, 'generateId - generated', data: {'id': id});
    return id;
  }

  Future<Item> create({
    required String companyId,
    required String name,
    String? description,
    double defaultUnitPrice = 0,
    String? defaultTaxId,
    String? category,
    bool isActive = true,
  }) async {
    _log.debug(
      LogTags.repo,
      'create - starting',
      data: {'companyId': companyId, 'name': name},
    );
    try {
      final id = await generateId();
      final now = DateTime.now();

      final item = Item(
        id: id,
        companyId: companyId,
        name: name,
        description: description,
        defaultUnitPrice: defaultUnitPrice,
        defaultTaxId: defaultTaxId,
        category: category,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      await insert(item);
      _log.info(
        LogTags.repo,
        'create - completed',
        data: {'id': id, 'name': name},
      );
      return item;
    } catch (e, st) {
      _log.error(LogTags.repo, 'create - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<List<String>> getCategories(String companyId) async {
    final items = await getAll(companyId);
    final categories = items
        .map((i) => i.category)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
