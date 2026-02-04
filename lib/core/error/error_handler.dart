/// EN: Error handler for mapping various exceptions to Failure types
/// KO: 다양한 예외를 Failure 타입으로 매핑하는 에러 핸들러
library;

import 'dart:io';

import 'package:dio/dio.dart';

import '../logging/app_logger.dart';
import 'failure.dart';

/// EN: Centralized error handler for the application
/// KO: 앱의 중앙화된 에러 핸들러
class ErrorHandler {
  ErrorHandler._();

  /// EN: Map DioException to appropriate Failure type
  /// KO: DioException을 적절한 Failure 타입으로 매핑
  static Failure mapDioError(DioException e) {
    AppLogger.error('DioError occurred', error: e, stackTrace: e.stackTrace);

    return switch (e.type) {
      DioExceptionType.connectionTimeout => NetworkFailure(
        'Connection timeout',
        code: 'connection_timeout',
        stackTrace: e.stackTrace,
      ),
      DioExceptionType.receiveTimeout => NetworkFailure(
        'Receive timeout',
        code: 'receive_timeout',
        stackTrace: e.stackTrace,
      ),
      DioExceptionType.sendTimeout => NetworkFailure(
        'Send timeout',
        code: 'send_timeout',
        stackTrace: e.stackTrace,
      ),
      DioExceptionType.badResponse => _mapStatusCode(
        e.response?.statusCode,
        e.response?.data,
        e.stackTrace,
      ),
      DioExceptionType.connectionError => NetworkFailure(
        'Connection error',
        code: 'connection_error',
        stackTrace: e.stackTrace,
      ),
      DioExceptionType.cancel => NetworkFailure(
        'Request cancelled',
        code: 'cancelled',
        stackTrace: e.stackTrace,
      ),
      _ => NetworkFailure(
        e.message ?? 'Network error',
        stackTrace: e.stackTrace,
      ),
    };
  }

  /// EN: Map HTTP status code to appropriate Failure type
  /// KO: HTTP 상태 코드를 적절한 Failure 타입으로 매핑
  static Failure _mapStatusCode(
    int? code,
    dynamic data,
    StackTrace? stackTrace,
  ) {
    final message = _extractErrorMessage(data);
    final errorCode = _extractErrorCode(data);
    final isCsrfFailure = _isCsrfFailure(message, data);

    return switch (code) {
      400 => ValidationFailure(
        message ?? 'Bad request',
        code: errorCode ?? '400',
        stackTrace: stackTrace,
        fieldErrors: _extractFieldErrors(data),
      ),
      401 => AuthFailure(
        message ?? 'Unauthorized',
        code: '401',
        stackTrace: stackTrace,
      ),
      403 => AuthFailure(
        message ?? 'Forbidden',
        code: isCsrfFailure ? 'auth_required' : '403',
        stackTrace: stackTrace,
      ),
      404 => NotFoundFailure(
        message ?? 'Not found',
        code: '404',
        stackTrace: stackTrace,
      ),
      422 => ValidationFailure(
        message ?? 'Validation error',
        code: errorCode ?? '422',
        stackTrace: stackTrace,
        fieldErrors: _extractFieldErrors(data),
      ),
      429 => ServerFailure(
        message ?? 'Too many requests',
        code: '429',
        stackTrace: stackTrace,
      ),
      500 => ServerFailure(
        message ?? 'Internal server error',
        code: '500',
        stackTrace: stackTrace,
      ),
      502 => ServerFailure(
        message ?? 'Bad gateway',
        code: '502',
        stackTrace: stackTrace,
      ),
      503 => ServerFailure(
        message ?? 'Service unavailable',
        code: '503',
        stackTrace: stackTrace,
      ),
      _ => ServerFailure(
        message ?? 'Unknown error ($code)',
        code: code?.toString(),
        stackTrace: stackTrace,
      ),
    };
  }

  /// EN: Extract error message from response data
  /// KO: 응답 데이터에서 에러 메시지 추출
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      // EN: Try common error message fields.
      // KO: 일반적인 에러 메시지 필드 시도.
      final message = data['message'];
      if (message is String) return message;

      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final nested = error['message'];
        if (nested is String) return nested;
      }
      if (error is String) return error;
    }
    return null;
  }

  /// EN: Check if response indicates CSRF failure.
  /// KO: 응답이 CSRF 실패를 나타내는지 확인합니다.
  static bool _isCsrfFailure(String? message, dynamic data) {
    final messageLower = message?.toLowerCase();
    if (messageLower != null && messageLower.contains('csrf')) {
      return true;
    }

    if (data is Map<String, dynamic>) {
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

  /// EN: Extract error code from response data
  /// KO: 응답 데이터에서 에러 코드를 추출
  static String? _extractErrorCode(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;

    final code = data['code'];
    if (code is String && code.isNotEmpty) return code;

    final error = data['error'];
    if (error is Map<String, dynamic>) {
      final nested = error['code'];
      if (nested is String && nested.isNotEmpty) return nested;
    }

    return null;
  }

  /// EN: Extract field-specific validation errors
  /// KO: 필드별 유효성 검증 에러 추출
  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;

    final fieldErrors = data['error']?['fieldErrors'] ?? data['fieldErrors'];
    if (fieldErrors == null || fieldErrors is! Map<String, dynamic>) {
      return null;
    }

    return fieldErrors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.cast<String>());
      }
      if (value is String) {
        return MapEntry(key, [value]);
      }
      return MapEntry(key, <String>[]);
    });
  }

  /// EN: Map general exceptions to Failure type
  /// KO: 일반 예외를 Failure 타입으로 매핑
  static Failure mapException(Object e, [StackTrace? stackTrace]) {
    AppLogger.error('Exception occurred', error: e, stackTrace: stackTrace);

    if (e is DioException) {
      return mapDioError(e);
    }

    if (e is SocketException) {
      return NetworkFailure(
        'No internet connection',
        code: 'no_internet',
        stackTrace: stackTrace,
      );
    }

    if (e is FormatException) {
      return ValidationFailure(
        'Invalid data format',
        code: 'format_error',
        stackTrace: stackTrace,
      );
    }

    if (e is Failure) {
      return e;
    }

    return UnknownFailure(e.toString(), stackTrace: stackTrace);
  }
}
