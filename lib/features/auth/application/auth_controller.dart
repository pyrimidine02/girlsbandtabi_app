/// EN: Authentication controller handling auth workflows.
/// KO: 인증 플로우를 처리하는 인증 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/oauth_provider.dart';
import '../domain/repositories/auth_repository.dart';
import 'oauth_service.dart';

/// EN: Authentication controller state (loading/error only).
/// KO: 인증 컨트롤러 상태 (로딩/에러만 관리).
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController({
    required AuthRepository repository,
    required AuthStateNotifier authStateNotifier,
    required AuthOAuthService oauthService,
  }) : _repository = repository,
       _authStateNotifier = authStateNotifier,
       _oauthService = oauthService,
       super(const AsyncData(null));

  final AuthRepository _repository;
  final AuthStateNotifier _authStateNotifier;
  final AuthOAuthService _oauthService;

  /// EN: Login with username/password.
  /// KO: 사용자명/비밀번호 로그인.
  Future<Result<void>> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _repository.login(
      username: username,
      password: password,
    );
    return _handleAuthResult(result);
  }

  /// EN: Register with username/password.
  /// KO: 사용자명/비밀번호 회원가입.
  Future<Result<void>> register({
    required String username,
    required String password,
    required String nickname,
  }) async {
    state = const AsyncLoading();
    final result = await _repository.register(
      username: username,
      password: password,
      nickname: nickname,
    );
    return _handleAuthResult(result);
  }

  /// EN: Complete OAuth login after receiving authorization code.
  /// KO: 인가 코드 수신 후 OAuth 로그인 완료.
  Future<Result<void>> completeOAuthLogin({
    required OAuthProvider provider,
    required String code,
    String? stateParam,
  }) async {
    state = const AsyncLoading();
    final result = await _repository.exchangeOAuthCode(
      provider: provider,
      code: code,
      state: stateParam,
    );
    return _handleAuthResult(result);
  }

  /// EN: Launch OAuth login flow.
  /// KO: OAuth 로그인 플로우 실행.
  Future<Result<void>> startOAuthLogin(OAuthProvider provider) async {
    return _oauthService.launch(provider);
  }

  /// EN: Log out and clear tokens.
  /// KO: 로그아웃 및 토큰 삭제.
  Future<void> logout() async {
    state = const AsyncLoading();
    final result = await _repository.logout();
    if (result is Err<void>) {
      state = AsyncError(result.failure, StackTrace.current);
      return;
    }
    _authStateNotifier.setUnauthenticated();
    state = const AsyncData(null);
  }

  Future<Result<void>> _handleAuthResult(Result<dynamic> result) async {
    if (result is Success<dynamic>) {
      _authStateNotifier.setAuthenticated();
      state = const AsyncData(null);
      return const Result.success(null);
    }

    if (result is Err<dynamic>) {
      final failure = result.failure;
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    state = AsyncError(
      const UnknownFailure('Unknown auth result', code: 'unknown_auth_result'),
      StackTrace.current,
    );
    return Result.failure(
      const UnknownFailure('Unknown auth result', code: 'unknown_auth_result'),
    );
  }
}

/// EN: Provider for AuthOAuthService.
/// KO: AuthOAuthService 프로바이더.
final authOAuthServiceProvider = Provider<AuthOAuthService>((ref) {
  return AuthOAuthService();
});

/// EN: Provider for AuthRepository.
/// KO: AuthRepository 프로바이더.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(apiClient),
    secureStorage: secureStorage,
  );
});

/// EN: Provider for AuthController.
/// KO: AuthController 프로바이더.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      final authStateNotifier = ref.read(authStateProvider.notifier);
      final oauthService = ref.watch(authOAuthServiceProvider);
      return AuthController(
        repository: repository,
        authStateNotifier: authStateNotifier,
        oauthService: oauthService,
      );
    });
