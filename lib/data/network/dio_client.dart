import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../datasources/local/secure_storage_service.dart';

part 'dio_client.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return DioClient(secureStorage).dio;
}

class DioClient {
  final Dio dio;
  final SecureStorageService secureStorage;

  DioClient(this.secureStorage)
      : dio = Dio(BaseOptions(
          baseUrl: 'https://api.quotable.io', // Public API for demonstration
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )) {
    dio.interceptors.add(_authInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Here we simulate checking for a token
        final token = await secureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Global error handling, could handle 401 Unauthorized
        if (e.response?.statusCode == 401) {
          // Trigger logout or token refresh logic
        }
        return handler.next(e);
      },
    );
  }
}
