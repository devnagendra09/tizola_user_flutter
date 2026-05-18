import 'dart:convert';

import 'package:flutter/foundation.dart';

class ApiLogger {
  static void logRequest({
    required String method,
    required Uri uri,
    required Map<String, String> params,
  }) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('════════════════════════════════════════');
    debugPrint('API REQUEST');
    debugPrint('Method: $method');
    debugPrint('URL: $uri');
    debugPrint('Params: ${jsonEncode(params)}');
    debugPrint('════════════════════════════════════════');
  }

  static void logResponse({
    required Uri uri,
    required int statusCode,
    required String body,
    required Duration duration,
  }) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('════════════════════════════════════════');
    debugPrint('API RESPONSE');
    debugPrint('URL: $uri');
    debugPrint('Status: $statusCode');
    debugPrint('Duration: ${duration.inMilliseconds}ms');
    debugPrint('Body: $body');
    debugPrint('════════════════════════════════════════');
    debugPrint('');
  }

  static void logError({
    required Uri uri,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('════════════════════════════════════════');
    debugPrint('API ERROR');
    debugPrint('URL: $uri');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    debugPrint('════════════════════════════════════════');
    debugPrint('');
  }
}
