import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class Logger {
  static const String _tag = 'KONTA';

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = tag != null ? '[$tag]' : '[$_tag]';
    final levelStr = level.name.toUpperCase();
    final fullMessage = '$timestamp $prefix [$levelStr] $message';

    developer.log(
      fullMessage,
      time: DateTime.now(),
      level: level.index * 100,
      error: error,
      stackTrace: stackTrace,
    );

    if (error != null) {
      developer.log('$fullMessage - Error: $error', level: 900);
    }
  }

  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void method(
    String className,
    String methodName, [
    Map<String, dynamic>? params,
  ]) {
    final paramsStr = params != null && params.isNotEmpty
        ? ' - params: $params'
        : '';
    debug('$className.$methodName$paramsStr', tag: 'METHOD');
  }

  static void success(String message, {String? tag}) {
    info('✓ $message', tag: tag);
  }

  static void network(
    String operation,
    String endpoint, [
    Map<String, dynamic>? data,
  ]) {
    final dataStr = data != null ? ' - data: $data' : '';
    debug('NETWORK: $operation $endpoint$dataStr', tag: 'NETWORK');
  }

  static void db(String operation, String table, [Map<String, dynamic>? data]) {
    final dataStr = data != null ? ' - $data' : '';
    debug('DB: $operation on $table$dataStr', tag: 'DATABASE');
  }

  static void sync(String operation, [String? details]) {
    final detailsStr = details != null ? ' - $details' : '';
    info('SYNC: $operation$detailsStr', tag: 'SYNC');
  }

  static void auth(String operation, [String? userId]) {
    final userStr = userId != null ? ' (user: $userId)' : '';
    info('AUTH: $operation$userStr', tag: 'AUTH');
  }

  static void ui(String screen, String action, [String? details]) {
    final detailsStr = details != null ? ' - $details' : '';
    debug('UI: $screen - $action$detailsStr', tag: 'UI');
  }
}
