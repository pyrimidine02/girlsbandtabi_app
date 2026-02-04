/// EN: Authentication repository implementation.
/// KO: 인증 리포지토리 구현체.
library;

import '../../../../core/error/failure.dart';
import '../../../../core/security/secure_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/oauth_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../dto/login_request.dart';
import '../dto/register_request.dart';
import '../dto/refresh_token_request.dart';
import '../dto/token_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorage secureStorage,
    DateTime Function()? now,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorage = secureStorage,
       _now = now ?? DateTime.now;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;
  final DateTime Function() _now;

  @override
  Future<Result<AuthTokens>> login({
    required String username,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      LoginRequest(username: username, password: password),
    );
    return _persistTokens(result);
  }

  @override
  Future<Result<AuthTokens>> register({
    required String username,
    required String password,
    required String nickname,
  }) async {
    final result = await _remoteDataSource.register(
      RegisterRequest(
        username: username,
        password: password,
        nickname: nickname,
      ),
    );
    return _persistTokens(result);
  }

  @override
  Future<Result<AuthTokens>> refresh() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return Result.failure(
        const ValidationFailure('Refresh token missing', code: 'missing_token'),
      );
    }

    final result = await _remoteDataSource.refresh(
      RefreshTokenRequest(refreshToken: refreshToken),
    );
    return _persistTokens(result);
  }

  @override
  Future<Result<void>> logout() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    final request = refreshToken != null && refreshToken.isNotEmpty
        ? RefreshTokenRequest(refreshToken: refreshToken)
        : null;

    final result = await _remoteDataSource.logout(request);
    await _secureStorage.clearTokens();
    return result;
  }

  @override
  Future<Result<AuthTokens>> exchangeOAuthCode({
    required OAuthProvider provider,
    required String code,
    String? state,
  }) async {
    final result = await _remoteDataSource.exchangeOAuthCode(
      provider: provider,
      code: code,
      state: state,
    );
    return _persistTokens(result);
  }

  Future<Result<AuthTokens>> _persistTokens(
    Result<TokenResponse> result,
  ) async {
    if (result is Success<TokenResponse>) {
      final tokenResponse = result.data;
      await _secureStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      final expiry = tokenResponse.resolvedExpiry(_now());
      if (expiry != null) {
        await _secureStorage.saveTokenExpiry(expiry);
      }

      return Result.success(AuthTokens.fromResponse(tokenResponse));
    }

    if (result is Err<TokenResponse>) {
      return Result.failure(result.failure);
    }

    return Result.failure(
      const UnknownFailure('Unknown auth result', code: 'unknown_result'),
    );
  }
}
