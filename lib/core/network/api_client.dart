import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import 'api_envelope.dart';

/// EN: Provider for ApiClient
/// KO: ApiClient 프로바이더
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.instance;
});

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  late final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isAuthEndpoint = options.path == ApiConstants.refresh ||
              options.path == ApiConstants.login ||
              options.path == ApiConstants.register ||
              options.extra['skipAuth'] == true;

          if (!isAuthEndpoint) {
            final token = await _secureStorage.read(key: 'access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else {
            options.headers.remove('Authorization');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.path != ApiConstants.refresh) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final newToken = await _secureStorage.read(key: 'access_token');
              final mergedHeaders =
                  Map<String, dynamic>.from(error.requestOptions.headers);
              if (newToken != null && newToken.isNotEmpty) {
                mergedHeaders['Authorization'] = 'Bearer $newToken';
              }
              try {
                final clonedRequest = await _dio.request<dynamic>(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: mergedHeaders,
                  ),
                );
                handler.resolve(clonedRequest);
                return;
              } on DioException catch (retryError) {
                handler.next(retryError);
                return;
              }
            } else {
              await _clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _dio.post<dynamic>(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null},
          extra: {'skipAuth': true},
        ),
      );

      final envelope = _processResponse(
        response,
        expectEnvelope: true,
      );

      final payload = envelope.requireDataAsMap();
      final accessToken = payload['accessToken']?.toString();
      final refresh = payload['refreshToken']?.toString();
      if (accessToken == null || refresh == null) {
        return false;
      }
      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  Future<Response<T>> getRaw<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiEnvelope> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool expectEnvelope = true,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(
        response,
        expectEnvelope: expectEnvelope,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiEnvelope> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool expectEnvelope = true,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(
        response,
        expectEnvelope: expectEnvelope,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiEnvelope> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool expectEnvelope = true,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(
        response,
        expectEnvelope: expectEnvelope,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiEnvelope> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool expectEnvelope = true,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(
        response,
        expectEnvelope: expectEnvelope,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiEnvelope> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool expectEnvelope = true,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(
        response,
        expectEnvelope: expectEnvelope,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiEnvelope _processResponse(
    Response<dynamic> response, {
    required bool expectEnvelope,
  }) {
    final statusCode = response.statusCode;
    final body = response.data;

    if (expectEnvelope && body is Map<String, dynamic>) {
      if (body.containsKey('success')) {
        final envelope = ApiEnvelope.fromJson(body, statusCode: statusCode);
        if (!envelope.isSuccess) {
          throw ApiException.fromEnvelope(envelope);
        }
        return envelope;
      }

      if (body.containsKey('error') && !body.containsKey('success')) {
        final merged = <String, dynamic>{'success': false, ...body};
        final envelope = ApiEnvelope.fromJson(merged, statusCode: statusCode);
        throw ApiException.fromEnvelope(envelope);
      }

      final data = body.containsKey('data') ? body['data'] : body;
      final metadata = body['metadata'] is Map<String, dynamic>
          ? ApiResponseMetadata.fromJson(
              body['metadata'] as Map<String, dynamic>?,
            )
          : null;
      final pagination = body['pagination'] is Map<String, dynamic>
          ? ApiPagination.fromJson(
              body['pagination'] as Map<String, dynamic>?,
            )
          : null;

      return ApiEnvelope(
        success: statusCode != null ? statusCode >= 200 && statusCode < 300 : null,
        statusCode: statusCode,
        data: data,
        metadata: metadata,
        pagination: pagination,
        error: null,
        raw: body,
      );
    }

    if (expectEnvelope && body == null) {
      return ApiEnvelope(
        success: statusCode != null ? statusCode >= 200 && statusCode < 300 : null,
        statusCode: statusCode,
        data: null,
        metadata: null,
        pagination: null,
        error: null,
        raw: null,
      );
    }

    return ApiEnvelope.fallback(statusCode: statusCode, data: body);
  }

  ApiException _handleError(DioException error) {
    final response = error.response;
    if (response != null) {
      final body = response.data;
      if (body is Map<String, dynamic>) {
        if (body.containsKey('success') || body.containsKey('error')) {
          final serialized = body.containsKey('success')
              ? body
              : <String, dynamic>{'success': false, ...body};
          final envelope = ApiEnvelope.fromJson(serialized, statusCode: response.statusCode);
          return ApiException.fromEnvelope(envelope);
        }
        if (body.containsKey('message')) {
          return ApiException(
            message: body['message']?.toString() ?? '요청 처리에 실패했습니다.',
            statusCode: response.statusCode,
          );
        }
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: '연결 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');
      case DioExceptionType.connectionError:
        return const ApiException(message: '네트워크 연결을 확인해주세요.');
      case DioExceptionType.badResponse:
        return ApiException(
          message: error.message ?? '요청 처리에 실패했습니다.',
          statusCode: response?.statusCode,
        );
      default:
        return ApiException(
          message: error.message ?? '알 수 없는 오류가 발생했습니다.',
          statusCode: response?.statusCode,
        );
    }
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.metadata,
    this.error,
  });

  factory ApiException.fromEnvelope(ApiEnvelope envelope) {
    final error = envelope.error;
    final message = error?.message ?? '요청 처리에 실패했습니다.';
    return ApiException(
      message: message,
      statusCode: envelope.statusCode,
      code: error?.code,
      metadata: envelope.metadata,
      error: error,
    );
  }

  final String message;
  final int? statusCode;
  final String? code;
  final ApiResponseMetadata? metadata;
  final ApiErrorDetails? error;

  List<ApiFieldError> get fieldErrors => error?.fieldErrors ?? const [];

  @override
  String toString() {
    return 'ApiException(status: $statusCode, code: $code, message: $message)';
  }
}
