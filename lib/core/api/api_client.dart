import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';

class ApiClient {
  static Dio createDio() {
    final baseUrl = kIsWeb
        ? ApiEndpoints.baseUrlWeb
        : ApiEndpoints.baseUrlAndroid;

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // JWT interceptor — adds Bearer token to every request
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: replace with real Firebase token when Firebase is configured
        // final user = FirebaseAuth.instance.currentUser;
        // final token = await user?.getIdToken() ?? 'dev-token';
        const token = 'dev-token';
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('Response: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ));
    }

    return dio;
  }
}
