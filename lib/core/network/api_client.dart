/// EN: Dio-based API client with JWT interceptor and error handling
/// KO: JWT 인터셉터와 에러 처리를 포함한 Dio 기반 API 클라이언트
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../error/error_handler.dart';
import '../error/failure.dart';
import '../logging/app_logger.dart';
import '../security/secure_storage.dart';
import '../utils/result.dart';

/// EN: API client for making HTTP requests
/// KO: HTTP 요청을 위한 API 클라이언트
class ApiClient {
  ApiClient({
    required SecureStorage secureStorage,
    VoidCallback? onUnauthorized,
    Dio? dio,
  }) : _secureStorage = secureStorage,
       _onUnauthorized = onUnauthorized,
       _dio = dio ?? Dio() {
    _setupDio();
  }

  final Dio _dio;
  final SecureStorage _secureStorage;
  final VoidCallback? _onUnauthorized;

  /// EN: Setup Dio with base configuration and interceptors
  /// KO: 기본 구성 및 인터셉터로 Dio 설정
  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.instance.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiTimeouts.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiTimeouts.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiTimeouts.sendTimeout),
      headers: {
        ApiHeaders.contentType: ApiHeaders.applicationJson,
        ApiHeaders.clientType: ApiHeaders.clientTypeMobile,
      },
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(
        _secureStorage,
        _dio,
        onUnauthorized: _onUnauthorized,
      ),
      _LoggingInterceptor(),
    ]);
  }

  // ========================================
  // EN: GET Request
  // KO: GET 요청
  // ========================================
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Result.failure(ErrorHandler.mapDioError(e));
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  // ========================================
  // EN: POST Request
  // KO: POST 요청
  // ========================================
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Result.failure(ErrorHandler.mapDioError(e));
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  // ========================================
  // EN: PUT Request
  // KO: PUT 요청
  // ========================================
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Result.failure(ErrorHandler.mapDioError(e));
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  // ========================================
  // EN: PATCH Request
  // KO: PATCH 요청
  // ========================================
  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Result.failure(ErrorHandler.mapDioError(e));
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  // ========================================
  // EN: DELETE Request
  // KO: DELETE 요청
  // ========================================
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Result.failure(ErrorHandler.mapDioError(e));
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  // ========================================
  // EN: Response Handler
  // KO: 응답 핸들러
  // ========================================
  Result<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(dynamic)? fromJson,
  ) {
    final data = response.data;

    // EN: Handle ApiResponse wrapper
    // KO: ApiResponse 래퍼 처리
    if (data is Map<String, dynamic>) {
      final success = data['success'] as bool? ?? true;
      if (!success) {
        final error = data['error'];
        final message = error?['message'] as String? ?? 'Unknown error';
        final code = error?['code'] as String?;
        return Result.failure(ServerFailure(message, code: code));
      }

      // EN: Extract data from wrapper if present
      // KO: 래퍼에서 데이터 추출
      final responseData = data['data'] ?? data;

      if (fromJson != null) {
        try {
          return Result.success(fromJson(responseData));
        } catch (e, stackTrace) {
          AppLogger.error(
            'JSON parsing error',
            error: e,
            stackTrace: stackTrace,
          );
          return Result.failure(
            ValidationFailure(
              'Failed to parse response',
              stackTrace: stackTrace,
            ),
          );
        }
      }

      return Result.success(responseData as T);
    }

    if (fromJson != null) {
      return Result.success(fromJson(data));
    }

    return Result.success(data as T);
  }
}

/// EN: Auth interceptor for JWT token management
/// KO: JWT 토큰 관리를 위한 인증 인터셉터
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._secureStorage, this._dio, {this.onUnauthorized});

  final SecureStorage _secureStorage;
  final Dio _dio;
  final VoidCallback? onUnauthorized;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // EN: Skip auth for public endpoints
    // KO: 공개 엔드포인트는 인증 건너뛰기
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers[ApiHeaders.authorization] = '${ApiHeaders.bearer} $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 403 && _isCsrfFailure(err.response?.data)) {
      await _secureStorage.clearTokens();
      onUnauthorized?.call();
      return handler.next(err);
    }

    // EN: Handle 401 Unauthorized - try to refresh token
    // KO: 401 Unauthorized 처리 - 토큰 갱신 시도
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // EN: Retry original request with new token
          // KO: 새 토큰으로 원래 요청 재시도
          final token = await _secureStorage.getAccessToken();
          err.requestOptions.headers[ApiHeaders.authorization] =
              '${ApiHeaders.bearer} $token';

          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', error: e);
      } finally {
        _isRefreshing = false;
      }

      // EN: Clear tokens on refresh failure
      // KO: 갱신 실패 시 토큰 삭제
      await _secureStorage.clearTokens();
      onUnauthorized?.call();
    }

    handler.next(err);
  }

  bool _isCsrfFailure(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is String && error.toLowerCase().contains('csrf')) {
        return true;
      }
      final details = data['details'];
      if (details is List) {
        return details
            .whereType<String>()
            .any((detail) => detail.toLowerCase().contains('csrf'));
      }
      if (details is String && details.toLowerCase().contains('csrf')) {
        return true;
      }
    }
    return false;
  }

  /// EN: Refresh access token using refresh token
  /// KO: 리프레시 토큰을 사용하여 액세스 토큰 갱신
  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await _secureStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }
    } catch (e) {
      AppLogger.error('Token refresh request failed', error: e);
    }

    return false;
  }

  /// EN: Check if endpoint is public (no auth required)
  /// KO: 엔드포인트가 공개인지 확인 (인증 불필요)
  bool _isPublicEndpoint(String path) {
    const publicPaths = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.refresh,
      ApiEndpoints.homeSummary,
      ApiEndpoints.health,
    ];

    return publicPaths.any((p) => path.contains(p));
  }
}

/// EN: Logging interceptor for debugging
/// KO: 디버깅을 위한 로깅 인터셉터
class _LoggingInterceptor extends Interceptor {
  Map<String, dynamic>? _sanitizeMap(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;
      if (key.contains('token') ||
          key.contains('authorization') ||
          key.contains('access') ||
          key.contains('refresh')) {
        sanitized[entry.key] = '***';
        continue;
      }
      sanitized[entry.key] = value;
    }
    return sanitized;
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _sanitizeMap(data);
    }
    return data;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final startTime = DateTime.now();
    options.extra['startTime'] = startTime;

    AppLogger.network(options.method, options.uri.toString(), tag: 'Request');
    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug(
        'Query: ${options.queryParameters}',
        tag: 'Request',
      );
    }
    if (options.data != null) {
      AppLogger.debug(
        'Body: ${_sanitizeData(options.data)}',
        tag: 'Request',
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as DateTime?;
    final responseTime = startTime != null
        ? DateTime.now().difference(startTime).inMilliseconds
        : null;

    AppLogger.network(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      responseTimeMs: responseTime,
      tag: 'Response',
    );
    if (response.data != null) {
      AppLogger.debug(
        'Body: ${_sanitizeData(response.data)}',
        tag: 'Response',
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.network(
      err.requestOptions.method,
      err.requestOptions.uri.toString(),
      statusCode: err.response?.statusCode,
      tag: 'Error',
    );
    if (err.response?.data != null) {
      AppLogger.debug(
        'Body: ${_sanitizeData(err.response?.data)}',
        tag: 'Error',
      );
    }

    handler.next(err);
  }
}
