import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

/// EN: Use case for user login functionality
/// KO: 사용자 로그인 기능을 위한 유스케이스
class LoginUseCase {
  /// EN: Creates login use case with auth repository dependency
  /// KO: 인증 리포지터리 의존성을 가진 로그인 유스케이스 생성
  const LoginUseCase({
    required this.authRepository,
  });

  /// EN: Authentication repository for login operations
  /// KO: 로그인 작업을 위한 인증 리포지터리
  final AuthRepository authRepository;

  /// EN: Execute login operation with validation
  /// KO: 검증을 포함한 로그인 작업 실행
  Future<Result<AuthTokens>> call(LoginCredentials credentials) async {
    // EN: Validate input credentials
    // KO: 입력 자격 증명 검증
    final validationResult = _validateCredentials(credentials);
    if (validationResult != null) {
      return ResultFailure(validationResult);
    }

    // EN: Attempt login through repository
    // KO: 리포지터리를 통한 로그인 시도
    final result = await authRepository.login(credentials);
    
    return result.flatMapAsync((tokens) async {
      // EN: Store tokens if login successful
      // KO: 로그인 성공시 토큰 저장
      final storeResult = await authRepository.storeTokens(tokens);
      
      return storeResult.map((_) => tokens);
    });
  }

  /// EN: Validate login credentials
  /// KO: 로그인 자격 증명 검증
  ValidationFailure? _validateCredentials(LoginCredentials credentials) {
    return Validators.validateFields([
      () => Validators.validateEmail(credentials.username, fieldName: 'username'),
      () => Validators.validateRequired(credentials.password, 'password'),
    ]);
  }
}

/// EN: Parameters for login use case
/// KO: 로그인 유스케이스를 위한 매개변수
class LoginParams {
  /// EN: Creates login parameters
  /// KO: 로그인 매개변수 생성
  const LoginParams({
    required this.username,
    required this.password,
  });

  /// EN: Username (email format)
  /// KO: 사용자명(이메일 형식)
  final String username;

  /// EN: User password
  /// KO: 사용자 비밀번호
  final String password;

  /// EN: Convert to login credentials
  /// KO: 로그인 자격 증명으로 변환
  LoginCredentials toCredentials() => LoginCredentials(
        username: username,
        password: password,
      );
}
