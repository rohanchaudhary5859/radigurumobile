import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = '[Radiguru]';
  static bool _isInitialized = false;

  static void initialize() {
    _isInitialized = true;
    debugPrint('Logger initialized');
  }

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (!_isInitialized) return;
    if (kDebugMode) {
      final buffer = StringBuffer('$_tag DEBUG: $message');
      if (error != null) buffer.write('\nError: $error');
      if (stackTrace != null) buffer.write('\nStack trace: $stackTrace');
      debugPrint(buffer.toString());
    }
  }

  static void info(String message, {Object? data}) {
    if (!_isInitialized) return;
    if (kDebugMode) {
      final buffer = StringBuffer('$_tag INFO: $message');
      if (data != null) buffer.write('\nData: $data');
      debugPrint(buffer.toString());
    }
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (!_isInitialized) return;
    final buffer = StringBuffer('$_tag WARNING: $message');
    if (error != null) buffer.write('\nError: $error');
    if (stackTrace != null) buffer.write('\nStack trace: $stackTrace');
    debugPrint(buffer.toString());
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!_isInitialized) return;
    final buffer = StringBuffer('$_tag ERROR: $message');
    if (error != null) buffer.write('\nError: $error');
    if (stackTrace != null) buffer.write('\nStack trace: $stackTrace');
    debugPrint(buffer.toString());
  }

  static void api(String endpoint, {Map<String, dynamic>? request, dynamic response, Object? error}) {
    if (!_isInitialized) return;
    if (!kDebugMode) return;
    
    final buffer = StringBuffer('$_tag API: $endpoint');
    if (request != null) buffer.write('\nRequest: $request');
    if (response != null) buffer.write('\nResponse: $response');
    if (error != null) buffer.write('\nError: $error');
    debugPrint(buffer.toString());
  }
}
