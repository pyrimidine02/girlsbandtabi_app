import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/network_client.dart';
import '../../../../core/utils/result.dart';
import '../models/user_model.dart';

/// EN: Abstract interface for remote authentication data source
/// KO: 원격 인증 데이터 소스를 위한 추상 인터페이스
abstract interface class AuthRemoteDataSource {
  /// EN: Authenticate user with email and password
  /// KO: 이메일과 비밀번호로 사용자 인증
  Future<Result<AuthResponseModel>> login({
    required String username,
    required String password,
  });

  /// EN: Register new user account
  /// KO: 새 사용자 계정 등록
  Future<Result<AuthResponseModel>> register({
    required String username,
    required String password,
    required String nickname,
  });

  /// EN: Refresh authentication token
  /// KO: 인증 토큰 갱신
  Future<Result<AuthResponseModel>> refreshToken({
    required String refreshToken,
  });

  /// EN: Logout user session
  /// KO: 사용자 세션 로그아웃
  Future<Result<void>> logout();

  /// EN: Get current user profile
  /// KO: 현재 사용자 프로필 가져오기
  Future<Result<UserModel>> getCurrentUser();

  /// EN: Update user profile
  /// KO: 사용자 프로필 업데이트
  Future<Result<UserModel>> updateProfile({
    required String userId,
    required String displayName,
    String? avatarUrl,
  });

  /// EN: Request password reset via email
  /// KO: 이메일을 통한 비밀번호 재설정 요청
  Future<Result<void>> requestPasswordReset({
    required String email,
  });

  /// EN: Change user password
  /// KO: 사용자 비밀번호 변경
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// EN: Verify user email with token
  /// KO: 토큰으로 사용자 이메일 확인
  Future<Result<void>> verifyEmail({
    required String verificationToken,
  });

  /// EN: Resend email verification
  /// KO: 이메일 검증 재전송
  Future<Result<void>> resendEmailVerification();

  /// EN: Delete user account
  /// KO: 사용자 계정 삭제
  Future<Result<void>> deleteAccount();
}

/// EN: Implementation of remote authentication data source using network client
/// KO: 네트워크 클라이언트를 사용한 원격 인증 데이터 소스 구현
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// EN: Creates auth remote data source with network client
  /// KO: 네트워크 클라이언트를 사용해 인증 원격 데이터 소스 생성
  const AuthRemoteDataSourceImpl({
    required this.networkClient,
  });

  /// EN: Network client for HTTP operations
  /// KO: HTTP 작업을 위한 네트워크 클라이언트
  final NetworkClient networkClient;

  @override
  Future<Result<AuthResponseModel>> login({
    required String username,
    required String password,
  }) async {
    return networkClient.post<AuthResponseModel>(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
      },
      decoder: (json) => AuthResponseModel.fromJson(json),
    );
  }

  @override
  Future<Result<AuthResponseModel>> register({
    required String username,
    required String password,
    required String nickname,
  }) async {
    return networkClient.post<AuthResponseModel>(
      ApiConstants.register,
      data: {
        'username': username,
        'password': password,
        'nickname': nickname,
      },
      decoder: (json) => AuthResponseModel.fromJson(json),
    );
  }

  @override
  Future<Result<AuthResponseModel>> refreshToken({
    required String refreshToken,
  }) async {
    return networkClient.post<AuthResponseModel>(
      ApiConstants.refresh,
      data: {
        'refreshToken': refreshToken,
      },
      decoder: (json) => AuthResponseModel.fromJson(json),
    );
  }

  @override
  Future<Result<void>> logout() async {
    return networkClient.post<void>(
      ApiConstants.logout,
    );
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    return networkClient.get<UserModel>(
      ApiConstants.me,
      decoder: (json) => UserModel.fromJson(json),
    );
  }

  @override
  Future<Result<UserModel>> updateProfile({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) async {
    return networkClient.patch<UserModel>(
      '${ApiConstants.apiBase}/auth/profile',
      data: {
        'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
      decoder: (json) => UserModel.fromJson(json),
    );
  }

  @override
  Future<Result<void>> requestPasswordReset({
    required String email,
  }) async {
    return networkClient.post<void>(
      '${ApiConstants.apiBase}/auth/password-reset',
      data: {
        'email': email,
      },
    );
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return networkClient.patch<void>(
      '${ApiConstants.apiBase}/auth/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<Result<void>> verifyEmail({
    required String verificationToken,
  }) async {
    return networkClient.post<void>(
      '${ApiConstants.apiBase}/auth/verify-email',
      data: {
        'token': verificationToken,
      },
    );
  }

  @override
  Future<Result<void>> resendEmailVerification() async {
    return networkClient.post<void>(
      '${ApiConstants.apiBase}/auth/resend-verification',
    );
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return networkClient.delete<void>(
      '${ApiConstants.apiBase}/auth/account',
    );
  }
}
