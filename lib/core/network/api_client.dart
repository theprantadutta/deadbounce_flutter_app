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
        onError: (e, handler) async {
          final recovered = await _maybeRecoverFrom(e);
          if (recovered != null) {
            handler.resolve(recovered);
            return;
          }
          handler.next(e);
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

  /// Silently mints a fresh token when a request 401s. Returns true if a new
  /// token is now stored. Injected after construction (the auth repository
  /// depends on this client, so the wiring can't be a constructor arg).
  Future<bool> Function()? _sessionRefresher;

  /// In-flight refresh, so concurrent 401s share one re-exchange.
  Future<bool>? _refreshing;

  /// Marks a request we've already retried once, to prevent 401 loops.
  static const String _retriedFlag = 'db_retried_after_refresh';

  /// Wires the session refresher used to recover from 401s. Call once at boot.
  void attachSessionRefresher(Future<bool> Function() refresher) {
    _sessionRefresher = refresher;
  }

  /// On a 401 (other than the refresh endpoint itself, and only once per
  /// request), refresh the token and replay the original request. Returns the
  /// replayed response on success, or null to let the original error surface.
  Future<Response<dynamic>?> _maybeRecoverFrom(DioException e) async {
    final refresher = _sessionRefresher;
    final request = e.requestOptions;
    if (refresher == null ||
        e.response?.statusCode != 401 ||
        request.path.contains('/auth/firebase') ||
        request.extra[_retriedFlag] == true) {
      return null;
    }

    final refreshed = await (_refreshing ??= refresher());
    _refreshing = null;
    if (!refreshed) return null;

    final token = await _tokenStorage.readAccessToken();
    final headers = Map<String, dynamic>.from(request.headers);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      return await _dio.fetch<dynamic>(
        request.copyWith(
          headers: headers,
          extra: {...request.extra, _retriedFlag: true},
        ),
      );
    } on DioException {
      return null; // replay failed — surface the original error path
    }
  }

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

  /// Lightweight reachability probe against the unauthenticated `/health`
  /// endpoint (which sits at the API ROOT, not under `/api/v1`, so we pass an
  /// absolute URL to bypass the base path). Short timeout so a down/slow
  /// server is detected fast. Never throws — returns false on any failure.
  /// The sync worker gates draining on this so queued events aren't burned
  /// against an unreachable server.
  Future<bool> isHealthy() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.apiBaseUrl}/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return res.statusCode == 200 && res.data?['status'] == 'healthy';
    } catch (_) {
      return false;
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
