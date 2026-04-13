import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/sync/sync_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  Logger.method('Provider', 'syncServiceProvider', {'init': true});
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

final isSyncingProvider = StateProvider<bool>((ref) => false);

final syncControllerProvider = Provider<SyncController>((ref) {
  Logger.method('Provider', 'syncControllerProvider', {'init': true});
  return SyncController(ref);
});

class SyncController {
  final Ref _ref;
  Timer? _periodicTimer;

  SyncController(this._ref);

  Future<void> syncNow() async {
    Logger.method('SyncController', 'syncNow');
    _ref.read(isSyncingProvider.notifier).state = true;
    try {
      await _ref.read(syncServiceProvider).syncAll();
      Logger.success('Sync completed', tag: 'SYNC_CONTROLLER');
    } catch (e, st) {
      Logger.error(
        'Sync failed',
        tag: 'SYNC_CONTROLLER',
        error: e,
        stackTrace: st,
      );
    } finally {
      _ref.read(isSyncingProvider.notifier).state = false;
    }
  }

  void startPeriodicSync({Duration interval = const Duration(minutes: 1)}) {
    Logger.method('SyncController', 'startPeriodicSync', {
      'interval': interval.inSeconds,
    });
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) async {
      if (!_ref.read(isSyncingProvider)) {
        Logger.debug('Periodic sync triggered', tag: 'SYNC_CONTROLLER');
        await syncNow();
      }
    });
    Logger.success('Periodic sync started', tag: 'SYNC_CONTROLLER');
  }

  void stopPeriodicSync() {
    Logger.method('SyncController', 'stopPeriodicSync');
    _periodicTimer?.cancel();
    _periodicTimer = null;
    Logger.success('Periodic sync stopped', tag: 'SYNC_CONTROLLER');
  }

  Future<int> getPendingCount() async {
    final count = await _ref.read(syncServiceProvider).getPendingCount();
    Logger.debug('Pending sync count: $count', tag: 'SYNC_CONTROLLER');
    return count;
  }

  void dispose() {
    Logger.method('SyncController', 'dispose');
    stopPeriodicSync();
  }
}
