/// EN: Base exception class for the application
/// KO: 애플리케이션을 위한 기본 예외 클래스
class AppException implements Exception {
  /// EN: Exception message
  /// KO: 예외 메시지
  final String message;
  
  /// EN: Exception code for identification
  /// KO: 식별을 위한 예외 코드
  final String code;
  
  /// EN: Additional data for context
  /// KO: 컨텍스트를 위한 추가 데이터
  final Map<String, dynamic>? data;

  const AppException({
    required this.message,
    required this.code,
    this.data,
  });

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// EN: Server-related exceptions (API errors)
/// KO: 서버 관련 예외 (API 에러)
class ServerException extends AppException {
  /// EN: HTTP status code
  /// KO: HTTP 상태 코드
  final int? statusCode;

  const ServerException({
    required super.message,
    required super.code,
    this.statusCode,
    super.data,
  });

  @override
  String toString() => 'ServerException(code: $code, statusCode: $statusCode, message: $message)';
}

/// EN: Network connectivity exceptions
/// KO: 네트워크 연결 예외
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    required super.code,
    super.data,
  });

  @override
  String toString() => 'NetworkException(code: $code, message: $message)';
}

/// EN: Cache-related exceptions
/// KO: 캐시 관련 예외
class CacheException extends AppException {
  const CacheException({
    required super.message,
    required super.code,
    super.data,
  });

  @override
  String toString() => 'CacheException(code: $code, message: $message)';
}

/// EN: Authentication-related exceptions
/// KO: 인증 관련 예외
class AuthException extends AppException {
  const AuthException({
    required super.message,
    required super.code,
    super.data,
  });

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}

/// EN: Validation exceptions for user input
/// KO: 사용자 입력에 대한 검증 예외
class ValidationException extends AppException {
  /// EN: Field that failed validation
  /// KO: 검증에 실패한 필드
  final String? fieldName;

  const ValidationException({
    required super.message,
    required super.code,
    this.fieldName,
    super.data,
  });

  @override
  String toString() => 'ValidationException(code: $code, field: $fieldName, message: $message)';
}

/// EN: Storage and file system exceptions
/// KO: 저장소 및 파일 시스템 예외
class StorageException extends AppException {
  const StorageException({
    required super.message,
    required super.code,
    super.data,
  });

  @override
  String toString() => 'StorageException(code: $code, message: $message)';
}

/// EN: Permission and authorization exceptions
/// KO: 권한 및 인증 예외
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    required super.code,
    super.data,
  });

  @override
  String toString() => 'PermissionException(code: $code, message: $message)';
}