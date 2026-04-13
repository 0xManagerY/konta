import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/sync/sync_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

final isSyncingProvider = StateProvider<bool>((ref) => false);

final syncControllerProvider = Provider<SyncController>((ref) {
  return SyncController(ref);
});

class SyncController {
  final Ref _ref;
  Timer? _periodicTimer;

  SyncController(this._ref);

  Future<void> syncNow() async {
    _ref.read(isSyncingProvider.notifier).state = true;
    try {
      await _ref.read(syncServiceProvider).syncAll();
    } finally {
      _ref.read(isSyncingProvider.notifier).state = false;
    }
  }

  void startPeriodicSync({Duration interval = const Duration(minutes: 1)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) async {
      if (!_ref.read(isSyncingProvider)) {
        await syncNow();
      }
    });
  }

  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<int> getPendingCount() async {
    return _ref.read(syncServiceProvider).getPendingCount();
  }

  void dispose() {
    stopPeriodicSync();
  }
}
