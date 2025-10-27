import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  static void warning(String message, {dynamic error}) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
      if (error != null) debugPrint('Error: $error');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }
}

