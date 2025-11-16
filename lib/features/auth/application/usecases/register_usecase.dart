import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

/// EN: Use case for user registration functionality
/// KO: 사용자 등록 기능을 위한 유스케이스
class RegisterUseCase {
  /// EN: Creates register use case with auth repository dependency
  /// KO: 인증 리포지터리 의존성을 가진 등록 유스케이스 생성
  const RegisterUseCase({
    required this.authRepository,
  });

  /// EN: Authentication repository for registration operations
  /// KO: 등록 작업을 위한 인증 리포지터리
  final AuthRepository authRepository;

  /// EN: Execute registration operation with validation
  /// KO: 검증을 포함한 등록 작업 실행
  Future<Result<AuthTokens>> call(RegisterCredentials credentials) async {
    // EN: Validate registration credentials
    // KO: 등록 자격 증명 검증
    final validationResult = _validateCredentials(credentials);
    if (validationResult != null) {
      return ResultFailure(validationResult);
    }

    // EN: Attempt registration through repository
    // KO: 리포지터리를 통한 등록 시도
    final result = await authRepository.register(credentials);
    
    return result.flatMapAsync((tokens) async {
      // EN: Store tokens if registration successful
      // KO: 등록 성공시 토큰 저장
      final storeResult = await authRepository.storeTokens(tokens);
      
      return storeResult.map((_) => tokens);
    });
  }

  /// EN: Validate registration credentials
  /// KO: 등록 자격 증명 검증
  ValidationFailure? _validateCredentials(RegisterCredentials credentials) {
    return Validators.validateFields([
      () => Validators.validateEmail(credentials.username, fieldName: 'username'),
      () => Validators.validatePassword(credentials.password),
      () => Validators.validateNickname(credentials.nickname),
    ]);
  }
}

/// EN: Parameters for register use case with password confirmation
/// KO: 비밀번호 확인이 포함된 등록 유스케이스 매개변수
class RegisterParams {
  /// EN: Creates register parameters
  /// KO: 등록 매개변수 생성
  const RegisterParams({
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.nickname,
  });

  /// EN: Username (email format)
  /// KO: 사용자명(이메일 형식)
  final String username;

  /// EN: User password
  /// KO: 사용자 비밀번호
  final String password;

  /// EN: Password confirmation
  /// KO: 비밀번호 확인
  final String confirmPassword;

  /// EN: Nickname displayed to other users
  /// KO: 다른 사용자에게 표시될 닉네임
  final String nickname;

  /// EN: Validate all parameters including password confirmation
  /// KO: 비밀번호 확인을 포함한 모든 매개변수 검증
  ValidationFailure? validate() {
    return Validators.validateFields([
      () => Validators.validateEmail(username, fieldName: 'username'),
      () => Validators.validatePassword(password),
      () => Validators.validatePasswordConfirmation(password, confirmPassword),
      () => Validators.validateNickname(nickname),
    ]);
  }

  /// EN: Convert to registration credentials
  /// KO: 등록 자격 증명으로 변환
  RegisterCredentials toCredentials() => RegisterCredentials(
        username: username,
        password: password,
        nickname: nickname,
      );
}
