import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/sync/sync_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/presentation/providers/sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncQueueHelper {
  final AppDatabase _db;
  final SyncService _syncService;

  SyncQueueHelper(this._db, this._syncService);

  Future<void> queueInsert(String table, String recordId) async {
    Logger.sync('QUEUE_INSERT', '$table/$recordId');
    await _syncService.queueOperation(
      table: table,
      operation: 'insert',
      recordId: recordId,
    );
  }

  Future<void> queueUpdate(String table, String recordId) async {
    Logger.sync('QUEUE_UPDATE', '$table/$recordId');
    await _syncService.queueOperation(
      table: table,
      operation: 'update',
      recordId: recordId,
    );
  }

  Future<void> queueDelete(String table, String recordId) async {
    Logger.sync('QUEUE_DELETE', '$table/$recordId');
    await _syncService.queueOperation(
      table: table,
      operation: 'delete',
      recordId: recordId,
    );
  }
}

final syncQueueHelperProvider = Provider<SyncQueueHelper>((ref) {
  final db = ref.watch(databaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  return SyncQueueHelper(db, syncService);
});
