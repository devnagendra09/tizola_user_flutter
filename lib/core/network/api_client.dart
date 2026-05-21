import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_response.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await _dio.get<Object?>(endpoint);
      return ApiResponse(
        statusCode: response.statusCode ?? 0,
        body: _bodyAsString(response.data),
      );
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return ApiResponse(
          statusCode: response.statusCode ?? 0,
          body: _bodyAsString(response.data),
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse> post(
    String endpoint,
    Map<String, String> body,
  ) async {
    try {
      final response = await _dio.post<Object?>(
        endpoint,
        data: body,
      );
      return ApiResponse(
        statusCode: response.statusCode ?? 0,
        body: _bodyAsString(response.data),
      );
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return ApiResponse(
          statusCode: response.statusCode ?? 0,
          body: _bodyAsString(response.data),
        );
      }
      rethrow;
    }
  }

  String _bodyAsString(Object? data) {
    if (data == null) return '';
    if (data is String) return data;
    return jsonEncode(data);
  }
}
