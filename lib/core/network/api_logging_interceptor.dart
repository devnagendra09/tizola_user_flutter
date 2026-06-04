import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_logger.dart';

class ApiLoggingInterceptor extends Interceptor {
  final Map<RequestOptions, Stopwatch> _stopwatches = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    ApiLogger.logRequest(
      method: options.method,
      uri: options.uri,
      params: _requestParamsFrom(options),
    );
    _stopwatches[options] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final stopwatch = _stopwatches.remove(response.requestOptions);
    stopwatch?.stop();

    ApiLogger.logResponse(
      uri: response.requestOptions.uri,
      statusCode: response.statusCode ?? 0,
      body: _bodyAsString(response.data),
      duration: stopwatch?.elapsed ?? Duration.zero,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final stopwatch = _stopwatches.remove(err.requestOptions);
    stopwatch?.stop();

    if (err.response != null) {
      ApiLogger.logResponse(
        uri: err.requestOptions.uri,
        statusCode: err.response!.statusCode ?? 0,
        body: _bodyAsString(err.response!.data),
        duration: stopwatch?.elapsed ?? Duration.zero,
      );
    } else {
      ApiLogger.logError(
        uri: err.requestOptions.uri,
        error: err.message ?? err,
      );
    }
    handler.next(err);
  }

  Map<String, String> _requestParamsFrom(RequestOptions options) {
    final params = <String, String>{};

    for (final entry in options.queryParameters.entries) {
      params['query.${entry.key}'] = entry.value?.toString() ?? '';
    }

    final data = options.data;
    if (data is Map) {
      for (final entry in data.entries) {
        params['body.${entry.key}'] = entry.value?.toString() ?? '';
      }
    } else if (data != null) {
      params['body'] = data.toString();
    }

    return params;
  }

  String _bodyAsString(Object? data) {
    if (data == null) return '';
    if (data is String) return data;
    return jsonEncode(data);
  }
}
