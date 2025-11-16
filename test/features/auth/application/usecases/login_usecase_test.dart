import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:girlsbandtabi_app/core/error/failure.dart';
import 'package:girlsbandtabi_app/core/utils/result.dart';
import 'package:girlsbandtabi_app/features/auth/application/usecases/login_usecase.dart';
import 'package:girlsbandtabi_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:girlsbandtabi_app/features/auth/domain/repositories/auth_repository.dart';

/// EN: Mock implementation of AuthRepository for testing
/// KO: 테스트용 AuthRepository 모의 구현
class MockAuthRepository extends Mock implements AuthRepository {}

/// EN: Unit tests for LoginUseCase following Clean Architecture principles
/// KO: Clean Architecture 원칙을 따르는 LoginUseCase 단위 테스트
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  // EN: Test data setup
  // KO: 테스트 데이터 설정
  const validCredentials = LoginCredentials(
    username: 'test@example.com',
    password: 'ValidPass123',
  );

  const validTokens = AuthTokens(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_456',
    expiresIn: 3600,
  );

  setUpAll(() {
    // EN: Register fallback values for mocktail
    // KO: mocktail을 위한 대체 값 등록
    registerFallbackValue(validCredentials);
    registerFallbackValue(validTokens);
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(authRepository: mockAuthRepository);
  });

  group('LoginUseCase', () {
    test('EN: should return tokens when login is successful / KO: 로그인 성공시 토큰 반환해야 함', () async {
      // Arrange
      when(() => mockAuthRepository.login(any()))
          .thenAnswer((_) async => Success(validTokens));
      when(() => mockAuthRepository.storeTokens(any()))
          .thenAnswer((_) async => const Success(null));

      // Act
      final result = await useCase(validCredentials);

      // Assert
      expect(result, isA<Success<AuthTokens>>());
      expect(result.data, equals(validTokens));
      
      // Verify repository calls
      verify(() => mockAuthRepository.login(validCredentials)).called(1);
      verify(() => mockAuthRepository.storeTokens(validTokens)).called(1);
    });

    test('EN: should return validation failure for invalid email / KO: 유효하지 않은 이메일에 대해 검증 실패 반환해야 함', () async {
      // Arrange
      const invalidCredentials = LoginCredentials(
        username: 'invalid-email',
        password: 'ValidPass123',
      );

      // Act
      final result = await useCase(invalidCredentials);

      // Assert
      expect(result, isA<ResultFailure<AuthTokens>>());
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.code, equals('INVALID_EMAIL_FORMAT'));
      
      // Verify repository is not called for validation failures
      verifyNever(() => mockAuthRepository.login(any()));
    });

    test('EN: should return validation failure for empty password / KO: 빈 비밀번호에 대해 검증 실패 반환해야 함', () async {
      // Arrange
      const invalidCredentials = LoginCredentials(
        username: 'test@example.com',
        password: '',
      );

      // Act
      final result = await useCase(invalidCredentials);

      // Assert
      expect(result, isA<ResultFailure<AuthTokens>>());
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.code, equals('FIELD_REQUIRED'));
      
      // Verify repository is not called for validation failures
      verifyNever(() => mockAuthRepository.login(any()));
    });

    test('EN: should return network failure when login API fails / KO: 로그인 API 실패시 네트워크 실패 반환해야 함', () async {
      // Arrange
      const networkFailure = NetworkFailure(
        message: 'Network connection failed',
        code: 'NETWORK_CONNECTION_FAILED',
      );
      
      when(() => mockAuthRepository.login(any()))
          .thenAnswer((_) async => const ResultFailure(networkFailure));

      // Act
      final result = await useCase(validCredentials);

      // Assert
      expect(result, isA<ResultFailure<AuthTokens>>());
      expect(result.failure, equals(networkFailure));
      
      // Verify login was attempted but store tokens was not called
      verify(() => mockAuthRepository.login(validCredentials)).called(1);
      verifyNever(() => mockAuthRepository.storeTokens(any()));
    });

    test('EN: should return auth failure for invalid credentials / KO: 유효하지 않은 자격 증명에 대해 인증 실패 반환해야 함', () async {
      // Arrange
      const authFailure = AuthFailure(
        message: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      );
      
      when(() => mockAuthRepository.login(any()))
          .thenAnswer((_) async => const ResultFailure(authFailure));

      // Act
      final result = await useCase(validCredentials);

      // Assert
      expect(result, isA<ResultFailure<AuthTokens>>());
      expect(result.failure, equals(authFailure));
      
      verify(() => mockAuthRepository.login(validCredentials)).called(1);
      verifyNever(() => mockAuthRepository.storeTokens(any()));
    });

    test('EN: should return storage failure when token storage fails / KO: 토큰 저장 실패시 저장소 실패 반환해야 함', () async {
      // Arrange
      const storageFailure = StorageFailure(
        message: 'Failed to store tokens',
        code: 'TOKEN_STORE_ERROR',
      );
      
      when(() => mockAuthRepository.login(any()))
          .thenAnswer((_) async => Success(validTokens));
      when(() => mockAuthRepository.storeTokens(any()))
          .thenAnswer((_) async => const ResultFailure(storageFailure));

      // Act
      final result = await useCase(validCredentials);

      // Assert
      expect(result, isA<ResultFailure<AuthTokens>>());
      expect(result.failure, equals(storageFailure));
      
      // Verify both calls were made
      verify(() => mockAuthRepository.login(validCredentials)).called(1);
      verify(() => mockAuthRepository.storeTokens(validTokens)).called(1);
    });

    test('EN: should validate multiple field errors correctly / KO: 여러 필드 오류를 올바르게 검증해야 함', () async {
      // Arrange
      const invalidCredentials = LoginCredentials(
        username: 'invalid-email',
        password: '',
      );

      // Act
      final result = await useCase(invalidCredentials);

      // Assert - Should return the first validation error (email)
      expect(result, isA<ResultFailure<AuthTokens>>());
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.code, equals('INVALID_EMAIL_FORMAT'));
    });
  });

  group('LoginParams', () {
    test('EN: should convert to credentials correctly / KO: 자격 증명으로 올바르게 변환해야 함', () {
      // Arrange
      const params = LoginParams(
        username: 'test@example.com',
        password: 'password123',
      );

      // Act
      final credentials = params.toCredentials();

      // Assert
      expect(credentials.username, equals('test@example.com'));
      expect(credentials.password, equals('password123'));
    });
  });
}
