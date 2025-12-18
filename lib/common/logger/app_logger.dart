import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$tagStr $message');
    }
  }

  static void e(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$tagStr ERROR: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack: $stackTrace');
      }
    }
  }

  static void i(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$tagStr INFO: $message');
    }
  }

  static void w(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$tagStr WARNING: $message');
    }
  }
}

