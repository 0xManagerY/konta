import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class TaxRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  TaxRepository(this._db, this._syncQueue);

  Future<List<Tax>> getAll(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getAll - fetching taxes',
      data: {'companyId': companyId},
    );
    try {
      final result = await _db.getTaxesByCompany(companyId);
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

  Future<Tax?> getById(String id) async {
    _log.debug(LogTags.repo, 'getById - fetching tax', data: {'id': id});
    try {
      final result = await _db.getTaxById(id);
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

  Future<void> insert(Tax tax) async {
    _log.debug(
      LogTags.repo,
      'insert - starting',
      data: {'id': tax.id, 'name': tax.name},
    );
    try {
      await _db.into(_db.taxes).insert(tax);
      await _syncQueue.queueInsert('taxes', tax.id);
      _log.info(LogTags.repo, 'insert - completed', data: {'id': tax.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'insert - failed',
        error: e,
        stack: st,
        data: {'id': tax.id},
      );
      rethrow;
    }
  }

  Future<void> update(Tax tax) async {
    _log.debug(LogTags.repo, 'update - starting', data: {'id': tax.id});
    try {
      await (_db.update(_db.taxes)..where((t) => t.id.equals(tax.id))).write(
        TaxesCompanion(
          name: Value(tax.name),
          rate: Value(tax.rate),
          description: Value(tax.description),
          isActive: Value(tax.isActive),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
      await _syncQueue.queueUpdate('taxes', tax.id);
      _log.info(LogTags.repo, 'update - completed', data: {'id': tax.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'update - failed',
        error: e,
        stack: st,
        data: {'id': tax.id},
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    try {
      await _syncQueue.queueDelete('taxes', id);
      await (_db.delete(_db.taxes)..where((t) => t.id.equals(id))).go();
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

  Future<String> generateId() async {
    final id = const Uuid().v4();
    _log.debug(LogTags.repo, 'generateId - generated', data: {'id': id});
    return id;
  }

  Future<Tax> create({
    required String companyId,
    required String name,
    required double rate,
    String? description,
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

      final tax = Tax(
        id: id,
        companyId: companyId,
        name: name,
        rate: rate,
        description: description,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      await insert(tax);
      _log.info(
        LogTags.repo,
        'create - completed',
        data: {'id': id, 'name': name},
      );
      return tax;
    } catch (e, st) {
      _log.error(LogTags.repo, 'create - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> createDefaults(String companyId) async {
    _log.debug(
      LogTags.repo,
      'createDefaults - starting',
      data: {'companyId': companyId},
    );
    try {
      await create(
        companyId: companyId,
        name: 'TVA 20%',
        rate: 20.0,
        description: 'Taux normal - Taxe sur les services',
      );

      await create(
        companyId: companyId,
        name: 'TVA 10%',
        rate: 10.0,
        description: 'Taux réduit - Taxe sur les gases',
      );

      await create(
        companyId: companyId,
        name: 'TVA 14%',
        rate: 14.0,
        description: 'Taux spécial',
      );

      await create(
        companyId: companyId,
        name: 'TVA 1%',
        rate: 1.0,
        description: 'Auto-entrepreneur - Article 91 CGI',
      );

      _log.info(LogTags.repo, 'createDefaults - completed');
    } catch (e, st) {
      _log.error(LogTags.repo, 'createDefaults - failed', error: e, stack: st);
      rethrow;
    }
  }
}
