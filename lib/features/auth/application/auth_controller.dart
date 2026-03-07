/// EN: Authentication controller handling auth workflows.
/// KO: 인증 플로우를 처리하는 인증 컨트롤러.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_manager.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/security/secure_storage.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/result.dart';
import '../../settings/application/settings_controller.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/oauth_provider.dart';
import '../domain/entities/register_consent.dart';
import '../domain/repositories/auth_repository.dart';
import 'oauth_service.dart';

/// EN: Authentication controller state (loading/error only).
/// KO: 인증 컨트롤러 상태 (로딩/에러만 관리).
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController({
    required AuthRepository repository,
    required AuthStateNotifier authStateNotifier,
    required AuthOAuthService oauthService,
    required Future<CacheManager> cacheManagerFuture,
    required SecureStorage secureStorage,
    required Future<LocalStorage> localStorageFuture,
    required Ref ref,
  }) : _repository = repository,
       _authStateNotifier = authStateNotifier,
       _oauthService = oauthService,
       _cacheManagerFuture = cacheManagerFuture,
       _secureStorage = secureStorage,
       _localStorageFuture = localStorageFuture,
       _ref = ref,
       super(const AsyncData(null));

  final AuthRepository _repository;
  final AuthStateNotifier _authStateNotifier;
  final AuthOAuthService _oauthService;
  final Future<CacheManager> _cacheManagerFuture;
  final SecureStorage _secureStorage;
  final Future<LocalStorage> _localStorageFuture;
  final Ref _ref;

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
    List<RegisterConsent> consents = const [],
  }) async {
    state = const AsyncLoading();
    final result = await _repository.register(
      username: username,
      password: password,
      nickname: nickname,
      consents: consents,
    );
    return _handleAuthResult(result);
  }

  /// EN: Send verification email for registration.
  /// KO: 회원가입용 이메일 인증 메일을 보냅니다.
  Future<Result<void>> sendEmailVerification({required String email}) async {
    final result = await _repository.sendEmailVerification(email: email);
    if (result is Err<void>) {
      final failure = result.failure;
      state = AsyncError(failure, StackTrace.current);
    }
    return result;
  }

  /// EN: Confirm verification token.
  /// KO: 이메일 인증 토큰을 확인합니다.
  Future<Result<void>> confirmEmailVerification({required String token}) async {
    final result = await _repository.confirmEmailVerification(token: token);
    if (result is Err<void>) {
      final failure = result.failure;
      state = AsyncError(failure, StackTrace.current);
    }
    return result;
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

  /// EN: Log out and clear ALL local data (tokens, caches, user-specific storage).
  /// KO: 로그아웃 시 모든 로컬 데이터를 삭제합니다 (토큰, 캐시, 사용자별 저장소).
  Future<void> logout() async {
    state = const AsyncLoading();
    final result = await _repository.logout();
    if (result is Err<void>) {
      AppLogger.warning(
        'Logout API failed; proceeding with local logout cleanup',
        data: result.failure,
        tag: 'AuthController',
      );
    }

    // EN: Best-effort remote push deactivation before clearing auth tokens.
    // KO: 인증 토큰 제거 전에 원격 푸시 등록 해제를 best-effort로 수행합니다.
    try {
      final remotePushService = _ref.read(remotePushServiceProvider);
      await remotePushService.deactivateCurrentDevice();
      await remotePushService.setAuthenticated(false);
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to deactivate remote push registration on logout',
        data: e,
        tag: 'AuthController',
      );
      AppLogger.error(
        'Remote push deactivation error on logout',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthController',
      );
    }

    // EN: 1. Clear all cached data (gbt_cache namespace in SharedPreferences).
    // KO: 1. 모든 캐시 데이터 삭제 (SharedPreferences의 gbt_cache 네임스페이스).
    await _clearAppCaches();

    // EN: 2. Clear ALL secure storage (tokens, userId, verification keys).
    // KO: 2. 모든 보안 저장소 삭제 (토큰, userId, 인증 키).
    await _clearSecureStorage();

    // EN: 3. Clear user-specific local storage data.
    // KO: 3. 사용자별 로컬 저장소 데이터 삭제.
    await _clearUserLocalStorage();

    // EN: 4. Invalidate Riverpod providers holding user-specific state.
    // KO: 4. 사용자별 상태를 보유한 Riverpod 프로바이더 초기화.
    _invalidateUserProviders();

    // EN: 5. Set auth state to unauthenticated.
    // KO: 5. 인증 상태를 미인증으로 설정.
    _authStateNotifier.setUnauthenticated();
    state = const AsyncData(null);

    AppLogger.info(
      'Logout complete: all user data cleared',
      tag: 'AuthController',
    );
  }

  Future<Result<void>> _handleAuthResult(Result<dynamic> result) async {
    if (result is Success<dynamic>) {
      final hasTokens = await _secureStorage.hasValidTokens();
      if (!hasTokens) {
        const failure = AuthFailure(
          'Authentication succeeded but tokens were not persisted',
          code: 'token_not_persisted',
        );
        state = AsyncError(failure, StackTrace.current);
        return Result.failure(failure);
      }
      await _clearAppCaches();
      _authStateNotifier.setAuthenticated();
      state = const AsyncData(null);
      unawaited(_requestNotificationPermissionOnLogin());
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

  /// EN: Prompt runtime notification permission after successful login.
  /// KO: 로그인 성공 직후 런타임 알림 권한을 요청합니다.
  Future<void> _requestNotificationPermissionOnLogin() async {
    try {
      final localStorage = await _localStorageFuture;
      final pushEnabled =
          localStorage.getBool(LocalStorageKeys.notificationsEnabled) ?? true;
      if (!pushEnabled) {
        return;
      }
      final remotePushService = _ref.read(remotePushServiceProvider);
      await remotePushService.initialize();
      await remotePushService.setAuthenticated(true);
      await remotePushService.requestPermission();
      await remotePushService.syncRegistration();

      final localNotifier = _ref.read(localNotificationsServiceProvider);
      await localNotifier.requestPermissions();
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to request notification permission after login',
        data: e,
        tag: 'AuthController',
      );
      AppLogger.error(
        'Notification permission request error',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthController',
      );
    }
  }

  /// EN: Clear app cache namespace on auth transitions.
  /// KO: 인증 상태 전환 시 앱 캐시 네임스페이스를 초기화합니다.
  Future<void> _clearAppCaches() async {
    try {
      final cacheManager = await _cacheManagerFuture;
      await cacheManager.clearAll();
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to clear app caches',
        data: e,
        tag: 'AuthController',
      );
      AppLogger.error(
        'App cache clear error',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthController',
      );
    }
  }

  /// EN: Clear ALL data from secure storage (tokens, userId, verification keys).
  /// KO: 보안 저장소의 모든 데이터 삭제 (토큰, userId, 인증 키).
  Future<void> _clearSecureStorage() async {
    try {
      await _secureStorage.clearAll();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to clear secure storage on logout',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthController',
      );
    }
  }

  /// EN: Clear user-specific data from local storage while preserving app settings.
  /// KO: 앱 설정은 유지하면서 사용자별 로컬 저장소 데이터를 삭제합니다.
  Future<void> _clearUserLocalStorage() async {
    try {
      final localStorage = await _localStorageFuture;
      await Future.wait([
        localStorage.remove(LocalStorageKeys.selectedProjectId),
        localStorage.remove(LocalStorageKeys.selectedProjectKey),
        localStorage.remove(LocalStorageKeys.selectedUnitIds),
        localStorage.remove(LocalStorageKeys.recentSearches),
        localStorage.remove(LocalStorageKeys.lastSyncTime),
        localStorage.remove(LocalStorageKeys.cachedHomeData),
        localStorage.remove(LocalStorageKeys.notificationDeviceId),
        localStorage.remove(LocalStorageKeys.notificationDeviceIdLegacy),
        localStorage.remove(LocalStorageKeys.notificationPushToken),
        localStorage.remove(LocalStorageKeys.userConsents),
        localStorage.remove(LocalStorageKeys.autoTranslationEnabled),
        localStorage.remove(LocalStorageKeys.privacyRequestHistory),
      ]);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to clear user local storage on logout',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthController',
      );
    }
  }

  /// EN: Invalidate Riverpod providers that hold user-specific data.
  /// KO: 사용자별 데이터를 보유한 Riverpod 프로바이더를 초기화합니다.
  void _invalidateUserProviders() {
    try {
      // EN: Reset project/unit selection state.
      // KO: 프로젝트/유닛 선택 상태 초기화.
      _ref.read(selectedProjectKeyProvider.notifier).state = null;
      _ref.read(selectedProjectIdProvider.notifier).state = null;
      _ref.read(selectedUnitIdsProvider.notifier).state = [];
      _ref.read(currentNavIndexProvider.notifier).state = 0;

      // EN: Invalidate user profile providers.
      // KO: 사용자 프로필 프로바이더 초기화.
      _ref.invalidate(userProfileControllerProvider);
      _ref.invalidate(notificationSettingsControllerProvider);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to invalidate providers on logout',
        error: e,
        stackTrace: stackTrace,
        tag: 'AuthController',
      );
    }
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
      final cacheManagerFuture = ref.watch(cacheManagerProvider.future);
      final secureStorage = ref.watch(secureStorageProvider);
      final localStorageFuture = ref.watch(localStorageProvider.future);
      return AuthController(
        repository: repository,
        authStateNotifier: authStateNotifier,
        oauthService: oauthService,
        cacheManagerFuture: cacheManagerFuture,
        secureStorage: secureStorage,
        localStorageFuture: localStorageFuture,
        ref: ref,
      );
    });
