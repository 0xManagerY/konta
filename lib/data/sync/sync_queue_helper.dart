import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_service.dart';
import 'package:konta/presentation/providers/sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncQueueHelper {
  final SyncService _syncService;
  final LogService _log = LogService();

  SyncQueueHelper(this._syncService);

  Future<void> queueInsert(String table, String recordId) async {
    _log.debug(
      LogTags.sync,
      'queueInsert - queuing insert',
      data: {'table': table, 'id': recordId},
    );
    await _syncService.queueOperation(
      table: table,
      operation: 'insert',
      recordId: recordId,
    );
  }

  Future<void> queueUpdate(String table, String recordId) async {
    _log.debug(
      LogTags.sync,
      'queueUpdate - queuing update',
      data: {'table': table, 'id': recordId},
    );
    await _syncService.queueOperation(
      table: table,
      operation: 'update',
      recordId: recordId,
    );
  }

  Future<void> queueDelete(String table, String recordId) async {
    _log.debug(
      LogTags.sync,
      'queueDelete - queuing delete',
      data: {'table': table, 'id': recordId},
    );
    await _syncService.queueOperation(
      table: table,
      operation: 'delete',
      recordId: recordId,
    );
  }
}

final syncQueueHelperProvider = Provider<SyncQueueHelper>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncQueueHelper(syncService);
});
