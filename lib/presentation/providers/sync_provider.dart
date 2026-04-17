import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/sync/sync_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/presentation/providers/sync_error_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final log = LogService();
  log.debug(LogTags.provider, 'syncServiceProvider - initializing');
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

final isSyncingProvider = StateProvider<bool>((ref) => false);

final syncControllerProvider = Provider<SyncController>((ref) {
  final log = LogService();
  log.debug(LogTags.provider, 'syncControllerProvider - initializing');
  return SyncController(ref);
});

class SyncController {
  final Ref _ref;
  final LogService _log = LogService();
  Timer? _periodicTimer;

  SyncController(this._ref);

  Future<void> syncNow() async {
    _log.debug(LogTags.sync, 'syncNow - starting');
    _ref.read(isSyncingProvider.notifier).state = true;
    try {
      await _ref
          .read(syncServiceProvider)
          .syncAll(
            onFailure:
                ({
                  required String table,
                  required String operation,
                  required String recordId,
                  required String error,
                  bool isPermanentFailure = false,
                }) {
                  _ref
                      .read(syncErrorProvider.notifier)
                      .recordError(
                        table: table,
                        operation: operation,
                        recordId: recordId,
                        error: error,
                        isPermanentFailure: isPermanentFailure,
                      );
                },
          );
      _log.info(LogTags.sync, 'syncNow - completed');
    } catch (e, st) {
      _log.error(LogTags.sync, 'syncNow - failed', error: e, stack: st);
      _ref
          .read(syncErrorProvider.notifier)
          .recordError(
            table: 'sync',
            operation: 'syncAll',
            recordId: 'n/a',
            error: e.toString(),
          );
    } finally {
      _ref.read(isSyncingProvider.notifier).state = false;
    }
  }

  void startPeriodicSync({Duration interval = const Duration(minutes: 1)}) {
    _log.debug(
      LogTags.sync,
      'startPeriodicSync - starting',
      data: {'intervalSeconds': interval.inSeconds},
    );
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) async {
      if (!_ref.read(isSyncingProvider)) {
        _log.debug(LogTags.sync, 'startPeriodicSync - triggered');
        await syncNow();
      }
    });
    _log.info(LogTags.sync, 'startPeriodicSync - started');
  }

  void stopPeriodicSync() {
    _log.debug(LogTags.sync, 'stopPeriodicSync - stopping');
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _log.info(LogTags.sync, 'stopPeriodicSync - stopped');
  }

  Future<int> getPendingCount() async {
    final count = await _ref.read(syncServiceProvider).getPendingCount();
    _log.debug(
      LogTags.sync,
      'getPendingCount - result',
      data: {'count': count},
    );
    return count;
  }

  void dispose() {
    _log.debug(LogTags.sync, 'dispose - disposing');
    stopPeriodicSync();
  }
}
