/// EN: Base failure class for error handling in Clean Architecture
/// KO: Clean Architecture에서 에러 처리를 위한 기본 실패 클래스
abstract class Failure {
  /// EN: Error message for display to users
  /// KO: 사용자에게 표시할 에러 메시지
  final String message;
  
  /// EN: Error code for debugging and logging
  /// KO: 디버깅 및 로깅을 위한 에러 코드
  final String code;
  
  /// EN: Additional data for error context
  /// KO: 에러 컨텍스트를 위한 추가 데이터
  final Map<String, dynamic>? data;

  const Failure({
    required this.message,
    required this.code,
    this.data,
  });

  @override
  String toString() => 'Failure(code: $code, message: $message)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => code.hashCode ^ message.hashCode;
}

/// EN: Network-related failures (HTTP errors, connectivity issues)
/// KO: 네트워크 관련 실패 (HTTP 에러, 연결 문제)
class NetworkFailure extends Failure {
  /// EN: HTTP status code if applicable
  /// KO: 해당하는 경우 HTTP 상태 코드
  final int? statusCode;

  const NetworkFailure({
    required super.message,
    required super.code,
    this.statusCode,
    super.data,
  });

  /// EN: Factory constructor for common network errors
  /// KO: 일반적인 네트워크 에러를 위한 팩토리 생성자
  factory NetworkFailure.connectionFailed() => const NetworkFailure(
        message: 'Network connection failed',
        code: 'NETWORK_CONNECTION_FAILED',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Request timeout',
        code: 'NETWORK_TIMEOUT',
      );

  factory NetworkFailure.serverError(int statusCode) => NetworkFailure(
        message: 'Server error occurred',
        code: 'SERVER_ERROR',
        statusCode: statusCode,
      );

  factory NetworkFailure.unauthorized() => const NetworkFailure(
        message: 'Unauthorized access',
        code: 'UNAUTHORIZED',
        statusCode: 401,
      );

  factory NetworkFailure.forbidden() => const NetworkFailure(
        message: 'Access forbidden',
        code: 'FORBIDDEN',
        statusCode: 403,
      );

  factory NetworkFailure.notFound() => const NetworkFailure(
        message: 'Resource not found',
        code: 'NOT_FOUND',
        statusCode: 404,
      );
}

/// EN: Authentication and authorization failures
/// KO: 인증 및 권한 실패
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    required super.code,
    super.data,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid username or password',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'User not found',
        code: 'USER_NOT_FOUND',
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'Username already in use',
        code: 'EMAIL_ALREADY_IN_USE',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak',
        code: 'WEAK_PASSWORD',
      );

  factory AuthFailure.tokenExpired() => const AuthFailure(
        message: 'Session expired, please login again',
        code: 'TOKEN_EXPIRED',
      );
}

/// EN: Validation failures for user input
/// KO: 사용자 입력에 대한 검증 실패
class ValidationFailure extends Failure {
  /// EN: Field name that failed validation
  /// KO: 검증에 실패한 필드 이름
  final String? fieldName;

  const ValidationFailure({
    required super.message,
    required super.code,
    this.fieldName,
    super.data,
  });

  factory ValidationFailure.required(String fieldName) => ValidationFailure(
        message: '$fieldName is required',
        code: 'FIELD_REQUIRED',
        fieldName: fieldName,
      );

  factory ValidationFailure.invalidEmail() => const ValidationFailure(
        message: 'Invalid email format',
        code: 'INVALID_EMAIL_FORMAT',
        fieldName: 'email',
      );

  factory ValidationFailure.invalidPassword() => const ValidationFailure(
        message: 'Password must be at least 8 characters',
        code: 'INVALID_PASSWORD',
        fieldName: 'password',
      );
}

/// EN: Cache and storage failures
/// KO: 캐시 및 저장소 실패
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    required super.code,
    super.data,
  });

  factory StorageFailure.accessDenied() => const StorageFailure(
        message: 'Storage access denied',
        code: 'STORAGE_ACCESS_DENIED',
      );

  factory StorageFailure.insufficientSpace() => const StorageFailure(
        message: 'Insufficient storage space',
        code: 'INSUFFICIENT_SPACE',
      );

  factory StorageFailure.corruptedData() => const StorageFailure(
        message: 'Corrupted data detected',
        code: 'CORRUPTED_DATA',
      );
}

/// EN: Business logic failures
/// KO: 비즈니스 로직 실패
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure({
    required super.message,
    required super.code,
    super.data,
  });

  factory BusinessLogicFailure.invalidOperation() => const BusinessLogicFailure(
        message: 'Invalid operation',
        code: 'INVALID_OPERATION',
      );

  factory BusinessLogicFailure.preconditionFailed() => const BusinessLogicFailure(
        message: 'Precondition failed',
        code: 'PRECONDITION_FAILED',
      );
}

/// EN: Unknown or unexpected failures
/// KO: 알려지지 않았거나 예상치 못한 실패
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    required super.code,
    super.data,
  });

  factory UnknownFailure.unexpected([String? details]) => UnknownFailure(
        message: details ?? 'An unexpected error occurred',
        code: 'UNKNOWN_ERROR',
      );
}
