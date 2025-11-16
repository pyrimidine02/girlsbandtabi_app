import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../entities/auth_credentials.dart';
import '../entities/user.dart';

/// EN: Abstract repository interface for authentication operations
/// KO: 인증 작업을 위한 추상 리포지터리 인터페이스
abstract interface class AuthRepository {
  /// EN: Login with username and password
  /// KO: 사용자명과 비밀번호로 로그인
  Future<Result<AuthTokens>> login(LoginCredentials credentials);

  /// EN: Register new user account
  /// KO: 새 사용자 계정 등록
  Future<Result<AuthTokens>> register(RegisterCredentials credentials);

  /// EN: Logout current user
  /// KO: 현재 사용자 로그아웃
  Future<Result<void>> logout();

  /// EN: Refresh access token using refresh token
  /// KO: 리프레시 토큰을 사용해 액세스 토큰 갱신
  Future<Result<AuthTokens>> refreshToken();

  /// EN: Get current authenticated user
  /// KO: 현재 인증된 사용자 가져오기
  Future<Result<User>> getCurrentUser();

  /// EN: Check if user is currently authenticated
  /// KO: 사용자가 현재 인증되었는지 확인
  Future<Result<bool>> isAuthenticated();

  /// EN: Request password reset via email
  /// KO: 이메일을 통한 비밀번호 재설정 요청
  Future<Result<void>> requestPasswordReset(PasswordResetRequest request);

  /// EN: Change user password
  /// KO: 사용자 비밀번호 변경
  Future<Result<void>> changePassword(PasswordChangeRequest request);

  /// EN: Update user profile information
  /// KO: 사용자 프로필 정보 업데이트
  Future<Result<User>> updateProfile(User updatedUser);

  /// EN: Delete user account
  /// KO: 사용자 계정 삭제
  Future<Result<void>> deleteAccount();

  /// EN: Verify user email with verification token
  /// KO: 검증 토큰으로 사용자 이메일 확인
  Future<Result<void>> verifyEmail(String verificationToken);

  /// EN: Resend email verification
  /// KO: 이메일 검증 재전송
  Future<Result<void>> resendEmailVerification();

  /// EN: Get stored authentication tokens
  /// KO: 저장된 인증 토큰 가져오기
  Future<Result<AuthTokens?>> getStoredTokens();

  /// EN: Store authentication tokens securely
  /// KO: 인증 토큰을 안전하게 저장
  Future<Result<void>> storeTokens(AuthTokens tokens);

  /// EN: Clear stored authentication tokens
  /// KO: 저장된 인증 토큰 지우기
  Future<Result<void>> clearTokens();
}
