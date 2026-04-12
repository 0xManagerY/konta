import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/sync/sync_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.syncQueue)).watch().map((list) => list.length);
});

final syncStatusProvider = StreamProvider<bool>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStatus;
});

final isSyncingProvider = StateProvider<bool>((ref) => false);

final syncControllerProvider = Provider<SyncController>((ref) {
  return SyncController(ref);
});

class SyncController {
  final Ref _ref;

  SyncController(this._ref);

  Future<void> syncNow() async {
    _ref.read(isSyncingProvider.notifier).state = true;
    try {
      await _ref.read(syncServiceProvider).syncAll();
    } finally {
      _ref.read(isSyncingProvider.notifier).state = false;
    }
  }

  Future<int> getPendingCount() async {
    return _ref.read(syncServiceProvider).getPendingCount();
  }
}
