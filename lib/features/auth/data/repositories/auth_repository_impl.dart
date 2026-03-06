/// EN: Authentication repository implementation.
/// KO: 인증 리포지토리 구현체.
library;

import 'dart:convert';

import '../../../../core/error/failure.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/security/secure_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/oauth_provider.dart';
import '../../domain/entities/register_consent.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../dto/email_verification_confirm_request.dart';
import '../dto/email_verification_request.dart';
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
    List<RegisterConsent> consents = const [],
  }) async {
    final primaryResult = await _remoteDataSource.register(
      RegisterRequest(
        username: username,
        password: password,
        nickname: nickname,
        consents: consents,
      ),
    );

    // EN: Compatibility fallback for backends that still reject `consents`.
    // KO: `consents` 필드를 아직 허용하지 않는 백엔드에 대한 하위호환 재시도입니다.
    if (consents.isNotEmpty &&
        primaryResult is Err<TokenResponse> &&
        _shouldRetryLegacyRegister(primaryResult.failure)) {
      final legacyResult = await _remoteDataSource.register(
        RegisterRequest(
          username: username,
          password: password,
          nickname: nickname,
        ),
      );
      return _persistTokens(legacyResult);
    }

    return _persistTokens(primaryResult);
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

  @override
  Future<Result<void>> sendEmailVerification({required String email}) {
    return _remoteDataSource.sendEmailVerification(
      EmailVerificationRequest(email: email),
    );
  }

  @override
  Future<Result<void>> confirmEmailVerification({required String token}) {
    return _remoteDataSource.confirmEmailVerification(
      EmailVerificationConfirmRequest(token: token),
    );
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

      final newUserId = _extractUserId(tokenResponse.accessToken);
      if (newUserId != null && newUserId.isNotEmpty) {
        final previousUserId = await _secureStorage.getUserId();
        if (previousUserId == null || previousUserId != newUserId) {
          await _secureStorage.clearVerificationKeys();
        }
        await _secureStorage.saveUserId(newUserId);
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

  String? _extractUserId(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length < 2) return null;
      final normalized = base64.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final jsonValue = jsonDecode(payload);
      if (jsonValue is Map<String, dynamic>) {
        final sub = jsonValue['sub'];
        return sub is String ? sub : null;
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to parse access token subject',
        data: e,
        tag: 'AuthRepository',
      );
      AppLogger.error(
        'Access token parse error',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthRepository',
      );
      return null;
    }
  }

  bool _shouldRetryLegacyRegister(Failure failure) {
    final normalizedMessage = failure.message.toLowerCase();
    final normalizedCode = (failure.code ?? '').toLowerCase();

    final mentionsConsents =
        normalizedMessage.contains('consents') ||
        normalizedCode.contains('consents');
    final likelyContractMismatch =
        normalizedMessage.contains('unrecognized') ||
        normalizedMessage.contains('unknown') ||
        normalizedMessage.contains('not allowed') ||
        normalizedMessage.contains('cannot deserialize') ||
        normalizedMessage.contains('json parse');

    return mentionsConsents && likelyContractMismatch;
  }
}
