/// Logging utility for cache operations with different levels (debug, info, warning, error).
abstract final class CacheLogger {
  static const String _prefix = '[Cache]';

  static void debug(String message) {
    debugPrint('$_prefix [DEBUG] $message');
  }

  static void info(String message) {
    debugPrint('$_prefix [INFO] $message');
  }

  static void warning(String message) {
    debugPrint('$_prefix [WARNING] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('$_prefix [ERROR] $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}

import 'dart:developer' as developer;

void debugPrint(String message) {
  developer.log(message, name: 'artisans_app');
}
