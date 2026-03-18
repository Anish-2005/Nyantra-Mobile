import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger._();
  static LogLevel minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  static void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minimumLevel.index) {
      return;
    }

    final tag = level.name.toUpperCase();
    final timestamp = DateTime.now().toUtc().toIso8601String();
    debugPrint('[$timestamp][$tag] $message');
    if (error != null) {
      debugPrint('[$timestamp][$tag] error: $error');
    }
    if (stackTrace != null && (kDebugMode || level == LogLevel.error)) {
      debugPrint('[$timestamp][$tag] stackTrace: $stackTrace');
    }
  }
}
