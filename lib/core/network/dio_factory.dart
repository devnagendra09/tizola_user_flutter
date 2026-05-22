import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'api_logging_interceptor.dart';

class DioFactory {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 25),
        headers: {'Accept': 'application/json'},
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
      ),
    );
    dio.interceptors.add(ApiLoggingInterceptor());
    return dio;
  }
}
