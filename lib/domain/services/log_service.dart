import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

enum LogLevel { debug, info, warn, error }

extension LogLevelExtension on LogLevel {
  String get colorCode {
    switch (this) {
      case LogLevel.debug:
        return '\x1B[90m';
      case LogLevel.info:
        return '\x1B[97m';
      case LogLevel.warn:
        return '\x1B[33m';
      case LogLevel.error:
        return '\x1B[31m';
    }
  }

  String get nameUpperCase => name.toUpperCase();
}

class LogEntry {
  final LogLevel level;
  final DateTime timestamp;
  final String tag;
  final String message;
  final Map<String, dynamic>? data;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.level,
    required this.timestamp,
    required this.tag,
    required this.message,
    this.data,
    this.error,
    this.stackTrace,
  });

  String get formattedTimestamp => timestamp.toUtc().toIso8601String();

  String get formattedData {
    if (data == null || data!.isEmpty) return '';
    final buffer = StringBuffer(' {');
    final entries = data!.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('${entry.key}=${entry.value}');
      if (i < entries.length - 1) buffer.write(', ');
    }
    buffer.write('}');
    return buffer.toString();
  }
}

abstract class LogOutput {
  void write(LogEntry entry);
  void flush() {}
}

class ConsoleOutput implements LogOutput {
  static const _reset = '\x1B[0m';

  @override
  void write(LogEntry entry) {
    final color = entry.level.colorCode;
    final reset = _reset;
    final timestamp = entry.formattedTimestamp;
    final level = entry.level.nameUpperCase;
    final tag = entry.tag;
    final message = entry.message;
    final data = entry.formattedData;

    String output;
    if (entry.error != null) {
      final errorStr = entry.error.toString();
      final stackStr = entry.stackTrace != null
          ? '\n${entry.stackTrace.toString().split('\n').take(3).join('\n')}'
          : '';
      output =
          '$color[$level] $timestamp $tag:$message$data\nError: $errorStr$stackStr$reset';
    } else {
      output = '$color[$level] $timestamp $tag:$message$data$reset';
    }

    if (kDebugMode) {
      print(output);
    }
  }

  @override
  void flush() {
    // Console output is immediate, no buffer to flush
  }
}

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;

  LogLevel minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  final List<LogOutput> _outputs = [];

  LogService._internal() {
    _outputs.add(ConsoleOutput());
  }

  List<LogOutput> get outputs => List.unmodifiable(_outputs);

  void addOutput(LogOutput output) {
    _outputs.add(output);
  }

  void removeOutput(LogOutput output) {
    _outputs.remove(output);
  }

  void clearOutputs() {
    _outputs.clear();
  }

  void _log(LogEntry entry) {
    if (entry.level.index < minLevel.index) return;

    for (final output in _outputs) {
      try {
        output.write(entry);
      } catch (e) {
        developer.log('LogOutput error: $e');
      }
    }
  }

  void debug(String tag, String message, {Map<String, dynamic>? data}) {
    _log(
      LogEntry(
        level: LogLevel.debug,
        timestamp: DateTime.now(),
        tag: tag,
        message: message,
        data: data,
      ),
    );
  }

  void info(String tag, String message, {Map<String, dynamic>? data}) {
    _log(
      LogEntry(
        level: LogLevel.info,
        timestamp: DateTime.now(),
        tag: tag,
        message: message,
        data: data,
      ),
    );
  }

  void warn(String tag, String message, {Map<String, dynamic>? data}) {
    _log(
      LogEntry(
        level: LogLevel.warn,
        timestamp: DateTime.now(),
        tag: tag,
        message: message,
        data: data,
      ),
    );
  }

  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogEntry(
        level: LogLevel.error,
        timestamp: DateTime.now(),
        tag: tag,
        message: message,
        error: error,
        stackTrace: stack,
        data: data,
      ),
    );
  }

  void log(
    LogLevel level,
    String tag,
    String message, {
    Map<String, dynamic>? data,
  }) {
    _log(
      LogEntry(
        level: level,
        timestamp: DateTime.now(),
        tag: tag,
        message: message,
        data: data,
      ),
    );
  }
}

class LogTags {
  static const String auth = 'Auth';
  static const String repo = 'Repo';
  static const String sync = 'Sync';
  static const String provider = 'Provider';
  static const String ui = 'UI';
  static const String nav = 'Nav';
  static const String validator = 'Validator';
  static const String service = 'Service';
  static const String db = 'DB';
  static const String supabase = 'Supabase';
  static const String perm = 'Perm';
  static const String config = 'Config';
}
