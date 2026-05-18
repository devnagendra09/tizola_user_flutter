import 'dart:convert';

import '../errors/failures.dart';

class ApiResponseParser {
  static Map<String, dynamic> decodeMap(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  static bool isValid(Map<String, dynamic> json) {
    return (json['err_code']?.toString().toLowerCase() ?? '') == 'valid';
  }

  static String message(Map<String, dynamic> json, [String fallback = '']) {
    return json['message']?.toString() ?? fallback;
  }
}
