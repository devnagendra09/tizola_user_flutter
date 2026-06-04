import 'dart:convert';

import 'package:flutter/foundation.dart';

class ApiLogger {
  static void logRequest({
    required String method,
    required Uri uri,
    required Map<String, String> params,
  }) {
    if (kReleaseMode) return;

    _printBlock(<String>[
      '════════════════════════════════════════',
      'API REQUEST',
      'Method: $method',
      'URL: $uri',
      'Params: ${jsonEncode(params)}',
      '════════════════════════════════════════',
    ]);
  }

  static void logResponse({
    required Uri uri,
    required int statusCode,
    required String body,
    required Duration duration,
  }) {
    if (kReleaseMode) return;

    final normalizedBody = _normalizeBody(body);
    _printBlock(<String>[
      '════════════════════════════════════════',
      'API RESPONSE',
      'URL: $uri',
      'Status: $statusCode',
      'Duration: ${duration.inMilliseconds}ms',
      'Body:',
      normalizedBody,
      '════════════════════════════════════════',
    ]);
  }

  static void logError({
    required Uri uri,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;

    final lines = <String>[
      '════════════════════════════════════════',
      'API ERROR',
      'URL: $uri',
      'Error: $error',
      if (stackTrace != null) 'StackTrace: $stackTrace',
      '════════════════════════════════════════',
    ];
    _printBlock(lines);
  }

  static void _printBlock(List<String> lines) {
    debugPrint('');
    for (final line in lines) {
      _printLong(line);
    }
    debugPrint('');
  }

  static void _printLong(String message) {
    const chunkSize = 800;
    if (message.length <= chunkSize) {
      debugPrint(message);
      return;
    }

    for (var i = 0; i < message.length; i += chunkSize) {
      final end = (i + chunkSize < message.length) ? i + chunkSize : message.length;
      debugPrint(message.substring(i, end));
    }
  }

  static String _normalizeBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return '(empty)';

    try {
      final decoded = jsonDecode(trimmed);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return body;
    }
  }
}
