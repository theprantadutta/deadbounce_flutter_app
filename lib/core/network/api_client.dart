import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import '../storage/token_storage.dart';

/// Exception surfaced by the network layer with a message safe to show
/// to the user.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin Dio wrapper: base URL from [AppConfig], JSON defaults, bearer-token
/// injection from [TokenStorage], and error normalization into
/// [ApiException]. Data sources call [get]/[post] and work with decoded
/// maps — they never touch Dio types.
class ApiClient {
  ApiClient(this._tokenStorage, {Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = AppConfig.apiV1
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Debug-only: log every request/response/error through Talker.
    if (kDebugMode) {
      _dio.interceptors.add(
        TalkerDioLogger(
          talker: AppLogger.talker,
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: false,
            printResponseHeaders: false,
            printResponseData: false,
          ),
        ),
      );
    }
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      return response.data ?? const {};
    } on DioException catch (e) {
      throw _normalize(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return response.data ?? const {};
    } on DioException catch (e) {
      throw _normalize(e);
    }
  }

  ApiException _normalize(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // The backend's error shape is { "error": "..." }.
    if (data is Map<String, dynamic> && data['error'] is String) {
      return ApiException(data['error'] as String, statusCode: statusCode);
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiException('Connection timed out. Check your network.'),
      DioExceptionType.connectionError =>
        ApiException('Cannot reach the Deadbounce servers.'),
      _ => ApiException(
          'Something went wrong. Please try again.',
          statusCode: statusCode,
        ),
    };
  }
}
