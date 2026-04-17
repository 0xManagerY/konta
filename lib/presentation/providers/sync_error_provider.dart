import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/domain/services/log_service.dart';

class SyncErrorState {
  final int failedCount;
  final String? lastError;
  final DateTime? lastErrorTime;
  final List<SyncErrorItem> recentErrors;
  const SyncErrorState({
    this.failedCount = 0,
    this.lastError,
    this.lastErrorTime,
    this.recentErrors = const [],
  });

  SyncErrorState copyWith({
    int? failedCount,
    String? lastError,
    DateTime? lastErrorTime,
    List<SyncErrorItem>? recentErrors,
  }) {
    return SyncErrorState(
      failedCount: failedCount ?? this.failedCount,
      lastError: lastError ?? this.lastError,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
      recentErrors: recentErrors ?? this.recentErrors,
    );
  }
}

class SyncErrorItem {
  final String table;
  final String operation;
  final String recordId;
  final String error;
  final DateTime timestamp;
  final bool isPermanentFailure;
  const SyncErrorItem({
    required this.table,
    required this.operation,
    required this.recordId,
    required this.error,
    required this.timestamp,
    this.isPermanentFailure = false,
  });
}

class SyncErrorNotifier extends StateNotifier<SyncErrorState> {
  final LogService _log = LogService();
  SyncErrorNotifier() : super(const SyncErrorState());

  void recordError({
    required String table,
    required String operation,
    required String recordId,
    required String error,
    bool isPermanentFailure = false,
  }) {
    _log.warn(
      LogTags.sync,
      'recordError - sync failure recorded',
      data: {
        'table': table,
        'operation': operation,
        'permanent': isPermanentFailure,
      },
    );
    final newError = SyncErrorItem(
      table: table,
      operation: operation,
      recordId: recordId,
      error: error,
      timestamp: DateTime.now(),
      isPermanentFailure: isPermanentFailure,
    );
    final recentErrors = [newError, ...state.recentErrors.take(4)];
    final newCount = state.failedCount + 1;
    state = state.copyWith(
      failedCount: newCount,
      lastError: error,
      lastErrorTime: DateTime.now(),
      recentErrors: recentErrors,
    );
  }

  void clearErrors() {
    _log.info(LogTags.sync, 'clearErrors - clearing sync errors');
    state = const SyncErrorState();
  }

  void dismissLastError() {
    if (state.recentErrors.isNotEmpty) {
      final recentErrors = state.recentErrors.sublist(1);
      state = state.copyWith(
        recentErrors: recentErrors,
        failedCount: state.failedCount > 0 ? state.failedCount - 1 : 0,
      );
    }
  }
}

final syncErrorProvider =
    StateNotifierProvider<SyncErrorNotifier, SyncErrorState>((ref) {
      final log = LogService();
      log.debug(LogTags.provider, 'syncErrorProvider - initializing');
      return SyncErrorNotifier();
    });

String getSyncErrorMessage(SyncErrorState state) {
  if (state.lastError == null) return '';
  if (state.failedCount == 1) {
    return 'Sync failed: ${state.lastError}';
  }
  return 'Sync failed: ${state.failedCount} errors (${state.lastError})';
}
