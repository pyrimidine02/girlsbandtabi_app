import 'package:equatable/equatable.dart';

/// EN: Value object representing login credentials
/// KO: 로그인 자격 증명을 나타내는 값 객체
class LoginCredentials extends Equatable {
  /// EN: Creates login credentials with username and password
  /// KO: 사용자명과 비밀번호로 로그인 자격 증명 생성
  const LoginCredentials({
    required this.username,
    required this.password,
  });

  /// EN: Username used for login (email format)
  /// KO: 로그인에 사용되는 사용자명(이메일 형식)
  final String username;

  /// EN: User's password
  /// KO: 사용자의 비밀번호
  final String password;

  @override
  List<Object> get props => [username, password];

  @override
  String toString() => 'LoginCredentials(username: $username)';
}

/// EN: Value object representing registration data
/// KO: 등록 데이터를 나타내는 값 객체
class RegisterCredentials extends Equatable {
  /// EN: Creates registration credentials
  /// KO: 등록 자격 증명 생성
  const RegisterCredentials({
    required this.username,
    required this.password,
    required this.nickname,
  });

  /// EN: Username for login (email format)
  /// KO: 로그인용 사용자명(이메일 형식)
  final String username;

  /// EN: User's password
  /// KO: 사용자의 비밀번호
  final String password;

  /// EN: Public nickname displayed to other users
  /// KO: 다른 사용자에게 표시될 닉네임
  final String nickname;

  @override
  List<Object> get props => [username, password, nickname];

  @override
  String toString() => 'RegisterCredentials(username: $username, nickname: $nickname)';
}

/// EN: Value object representing authentication tokens
/// KO: 인증 토큰을 나타내는 값 객체
class AuthTokens extends Equatable {
  /// EN: Creates authentication tokens
  /// KO: 인증 토큰 생성
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
  });

  /// EN: JWT access token for API requests
  /// KO: API 요청용 JWT 액세스 토큰
  final String accessToken;

  /// EN: Refresh token for renewing access token
  /// KO: 액세스 토큰 갱신용 리프레시 토큰
  final String refreshToken;

  /// EN: Optional expiration time in seconds
  /// KO: 선택적 만료 시간 (초)
  final int? expiresIn;

  /// EN: Check if tokens are empty/invalid
  /// KO: 토큰이 비어있거나 유효하지 않은지 확인
  bool get isEmpty => accessToken.isEmpty || refreshToken.isEmpty;

  /// EN: Check if tokens are valid
  /// KO: 토큰이 유효한지 확인
  bool get isValid => !isEmpty;

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];

  @override
  String toString() => 'AuthTokens(hasAccess: ${accessToken.isNotEmpty}, '
                      'hasRefresh: ${refreshToken.isNotEmpty}, '
                      'expiresIn: $expiresIn)';
}

/// EN: Value object representing password reset request
/// KO: 비밀번호 재설정 요청을 나타내는 값 객체
class PasswordResetRequest extends Equatable {
  /// EN: Creates password reset request with email
  /// KO: 이메일로 비밀번호 재설정 요청 생성
  const PasswordResetRequest({
    required this.email,
  });

  /// EN: Email address for password reset
  /// KO: 비밀번호 재설정용 이메일 주소
  final String email;

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'PasswordResetRequest(email: $email)';
}

/// EN: Value object representing password change request
/// KO: 비밀번호 변경 요청을 나타내는 값 객체
class PasswordChangeRequest extends Equatable {
  /// EN: Creates password change request
  /// KO: 비밀번호 변경 요청 생성
  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  /// EN: Current password for verification
  /// KO: 검증용 현재 비밀번호
  final String currentPassword;

  /// EN: New password to set
  /// KO: 설정할 새 비밀번호
  final String newPassword;

  @override
  List<Object> get props => [currentPassword, newPassword];

  @override
  String toString() => 'PasswordChangeRequest(hasCurrentPassword: ${currentPassword.isNotEmpty})';
}
