import 'package:flutter/foundation.dart';

/// Simple logger utility
class Logger {
  Logger._();

  static const String _prefix = '🎵 VibeLens';

  /// Log info message
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ℹ️  $message');
    }
  }

  /// Log success message
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ✅ $message');
    }
  }

  /// Log warning message
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ⚠️  $message');
    }
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_prefix ❌ $message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   Stack: $stackTrace');
      }
    }
  }

  /// Log debug message (only in debug mode)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🐛 $message');
    }
  }

  /// Log model inference details
  static void inference(String message, {int? timeMs}) {
    if (kDebugMode) {
      final time = timeMs != null ? ' (${timeMs}ms)' : '';
      debugPrint('$_prefix 🧠 $message$time');
    }
  }

  /// Log camera operation
  static void camera(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 📸 $message');
    }
  }

  /// Log Spotify operation
  static void spotify(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🎵 $message');
    }
  }
}
