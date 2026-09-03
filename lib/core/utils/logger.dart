import 'package:flutter/foundation.dart';

/// Centralized Logger for debug, info, warning, and error tracing
class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'DEBUG'}) {
    if (kDebugMode) {
      debugPrint('[$tag] 🔹 $message');
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    if (kDebugMode) {
      debugPrint('[$tag] ℹ️ $message');
    }
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    if (kDebugMode) {
      debugPrint('[$tag] ⚠️ $message');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    if (kDebugMode) {
      debugPrint('[$tag] ❌ $message');
      if (error != null) debugPrint('Error Detail: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
