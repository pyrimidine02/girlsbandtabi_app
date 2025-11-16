import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// EN: Implementation of AuthRepository interface following Clean Architecture
/// KO: Clean Architecture를 따르는 AuthRepository 인터페이스 구현
class AuthRepositoryImpl implements AuthRepository {
  /// EN: Creates auth repository with local and remote data sources
  /// KO: 로컬 및 원격 데이터 소스를 사용해 인증 리포지터리 생성
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// EN: Remote data source for API operations
  /// KO: API 작업을 위한 원격 데이터 소스
  final AuthRemoteDataSource remoteDataSource;

  /// EN: Local data source for caching and storage
  /// KO: 캐싱 및 저장을 위한 로컬 데이터 소스
  final AuthLocalDataSource localDataSource;

  @override
  Future<Result<AuthTokens>> login(LoginCredentials credentials) async {
    // EN: Attempt login through remote API
    // KO: 원격 API를 통한 로그인 시도
    final result = await remoteDataSource.login(
      username: credentials.username,
      password: credentials.password,
    );

    return result.flatMapAsync((authResponse) async {
      // EN: Extract tokens from response
      // KO: 응답에서 토큰 추출
      final tokens = authResponse.toTokens();

      // EN: Store tokens locally for future use
      // KO: 향후 사용을 위해 토큰을 로컬에 저장
      final storeResult = await localDataSource.storeTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // EN: Cache user if available in response
      // KO: 응답에 사용자가 있는 경우 캐시
      if (authResponse.user != null) {
        await localDataSource.cacheUser(authResponse.user!);
      }

      return storeResult.map((_) => tokens);
    });
  }

  @override
  Future<Result<AuthTokens>> register(RegisterCredentials credentials) async {
    // EN: Attempt registration through remote API
    // KO: 원격 API를 통한 등록 시도
    final result = await remoteDataSource.register(
      username: credentials.username,
      password: credentials.password,
      nickname: credentials.nickname,
    );

    return result.flatMapAsync((authResponse) async {
      // EN: Extract tokens from response
      // KO: 응답에서 토큰 추출
      final tokens = authResponse.toTokens();

      // EN: Store tokens locally
      // KO: 토큰을 로컬에 저장
      final storeResult = await localDataSource.storeTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // EN: Cache user if available
      // KO: 사용자가 있는 경우 캐시
      if (authResponse.user != null) {
        await localDataSource.cacheUser(authResponse.user!);
      }

      return storeResult.map((_) => tokens);
    });
  }

  @override
  Future<Result<void>> logout() async {
    // EN: First attempt logout on server (optional, can fail)
    // KO: 먼저 서버에서 로그아웃 시도 (선택사항, 실패 가능)
    await remoteDataSource.logout();

    // EN: Clear local tokens and cache (always do this)
    // KO: 로컬 토큰과 캐시 지우기 (항상 수행)
    final clearTokensResult = await localDataSource.clearTokens();
    final clearUserResult = await localDataSource.clearCachedUser();

    // EN: Return success if at least tokens are cleared
    // KO: 최소한 토큰이 지워진 경우 성공 반환
    return clearTokensResult.flatMap((_) => clearUserResult);
  }

  @override
  Future<Result<AuthTokens>> refreshToken() async {
    // EN: Get stored refresh token
    // KO: 저장된 리프레시 토큰 가져오기
    final refreshTokenResult = await localDataSource.getRefreshToken();

    return refreshTokenResult.flatMapAsync((refreshToken) async {
      if (refreshToken == null || refreshToken.isEmpty) {
        return const ResultFailure(AuthFailure(
          message: 'No refresh token available',
          code: 'NO_REFRESH_TOKEN',
        ));
      }

      // EN: Attempt token refresh through remote API
      // KO: 원격 API를 통한 토큰 갱신 시도
      final result = await remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );

      return result.flatMapAsync((authResponse) async {
        // EN: Extract new tokens
        // KO: 새 토큰 추출
        final tokens = authResponse.toTokens();

        // EN: Store new tokens
        // KO: 새 토큰 저장
        final storeResult = await localDataSource.storeTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );

        return storeResult.map((_) => tokens);
      });
    });
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    // EN: First try to get from cache
    // KO: 먼저 캐시에서 가져오기 시도
    final cachedUserResult = await localDataSource.getCachedUser();
    
    return cachedUserResult.flatMapAsync((cachedUser) async {
      if (cachedUser != null) {
        return Success(cachedUser.toEntity());
      }

      // EN: If not cached, fetch from remote
      // KO: 캐시되지 않은 경우 원격에서 가져오기
      final remoteResult = await remoteDataSource.getCurrentUser();

      return remoteResult.flatMapAsync((userModel) async {
        // EN: Cache the fetched user
        // KO: 가져온 사용자 캐시
        await localDataSource.cacheUser(userModel);

        return Success(userModel.toEntity());
      });
    });
  }

  @override
  Future<Result<bool>> isAuthenticated() async {
    return localDataSource.isLoggedIn();
  }

  @override
  Future<Result<void>> requestPasswordReset(PasswordResetRequest request) async {
    return remoteDataSource.requestPasswordReset(email: request.email);
  }

  @override
  Future<Result<void>> changePassword(PasswordChangeRequest request) async {
    return remoteDataSource.changePassword(
      currentPassword: request.currentPassword,
      newPassword: request.newPassword,
    );
  }

  @override
  Future<Result<User>> updateProfile(User updatedUser) async {
    final result = await remoteDataSource.updateProfile(
      userId: updatedUser.id,
      displayName: updatedUser.displayName,
      avatarUrl: updatedUser.avatarUrl,
    );

    return result.flatMapAsync((userModel) async {
      // EN: Update local cache with new data
      // KO: 새 데이터로 로컬 캐시 업데이트
      await localDataSource.cacheUser(userModel);

      return Success(userModel.toEntity());
    });
  }

  @override
  Future<Result<void>> deleteAccount() async {
    final result = await remoteDataSource.deleteAccount();

    return result.flatMapAsync((_) async {
      // EN: Clear all local data after account deletion
      // KO: 계정 삭제 후 모든 로컬 데이터 지우기
      await localDataSource.clearTokens();
      await localDataSource.clearCachedUser();

      return const Success(null);
    });
  }

  @override
  Future<Result<void>> verifyEmail(String verificationToken) async {
    return remoteDataSource.verifyEmail(
      verificationToken: verificationToken,
    );
  }

  @override
  Future<Result<void>> resendEmailVerification() async {
    return remoteDataSource.resendEmailVerification();
  }

  @override
  Future<Result<AuthTokens?>> getStoredTokens() async {
    final accessTokenResult = await localDataSource.getAccessToken();
    final refreshTokenResult = await localDataSource.getRefreshToken();

    return accessTokenResult.flatMap((accessToken) {
      return refreshTokenResult.map((refreshToken) {
        if (accessToken != null && refreshToken != null) {
          return AuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        return null;
      });
    });
  }

  @override
  Future<Result<void>> storeTokens(AuthTokens tokens) async {
    return localDataSource.storeTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  @override
  Future<Result<void>> clearTokens() async {
    return localDataSource.clearTokens();
  }
}
