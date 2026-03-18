import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger._();

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
    if (!kDebugMode && level == LogLevel.debug) {
      return;
    }

    final tag = level.name.toUpperCase();
    debugPrint('[$tag] $message');
    if (error != null) {
      debugPrint('[$tag] error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('[$tag] stackTrace: $stackTrace');
    }
  }
}
