/// EN: Core Riverpod providers for dependency injection
/// KO: 의존성 주입을 위한 핵심 Riverpod 프로바이더
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/connectivity_service.dart';
import '../cache/cache_manager.dart';
import '../network/api_client.dart';
import '../analytics/analytics_service.dart';
import '../location/location_service.dart';
import '../security/secure_storage.dart';
import '../storage/local_storage.dart';

// ========================================
// EN: Storage Providers
// KO: 저장소 프로바이더
// ========================================

/// EN: Secure storage provider for sensitive data
/// KO: 민감한 데이터를 위한 보안 저장소 프로바이더
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// EN: Local storage provider (async initialization required)
/// KO: 로컬 저장소 프로바이더 (비동기 초기화 필요)
final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  return LocalStorage.create();
});

/// EN: Cache manager provider (async initialization required).
/// KO: 캐시 매니저 프로바이더 (비동기 초기화 필요).
final cacheManagerProvider = FutureProvider<CacheManager>((ref) async {
  final localStorage = await ref.watch(localStorageProvider.future);
  return CacheManager(localStorage);
});

// ========================================
// EN: Network Providers
// KO: 네트워크 프로바이더
// ========================================

/// EN: API client provider
/// KO: API 클라이언트 프로바이더
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(
    secureStorage: secureStorage,
    onUnauthorized: ref.read(authStateProvider.notifier).setUnauthenticated,
  );
});

/// EN: Analytics service provider.
/// KO: 분석 서비스 프로바이더.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService.instance;
});

/// EN: Connectivity service provider
/// KO: 연결 서비스 프로바이더
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// EN: Location service provider.
/// KO: 위치 서비스 프로바이더.
final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

/// EN: Connectivity status stream provider
/// KO: 연결 상태 스트림 프로바이더
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// EN: Current connectivity status provider
/// KO: 현재 연결 상태 프로바이더
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return service.isOnline;
});

// ========================================
// EN: App State Providers
// KO: 앱 상태 프로바이더
// ========================================

/// EN: Theme mode provider (light/dark/system)
/// KO: 테마 모드 프로바이더 (라이트/다크/시스템)
final themeModeProvider = StateProvider<String>((ref) {
  return 'system';
});

/// EN: Selected project key provider (slug/code)
/// KO: 선택된 프로젝트 키 프로바이더 (slug/code)
final selectedProjectKeyProvider = StateProvider<String?>((ref) {
  return null;
});

/// EN: Selected project ID provider (UUID when available).
/// KO: 선택된 프로젝트 ID 프로바이더 (가능하면 UUID).
final selectedProjectIdProvider = StateProvider<String?>((ref) {
  return null;
});

/// EN: Selected unit IDs provider
/// KO: 선택된 유닛 ID 목록 프로바이더
final selectedUnitIdsProvider = StateProvider<List<String>>((ref) {
  return [];
});

/// EN: Current bottom navigation index.
/// KO: 현재 하단 네비게이션 인덱스.
final currentNavIndexProvider = StateProvider<int>((ref) {
  return 0;
});

// ========================================
// EN: Auth State Providers
// KO: 인증 상태 프로바이더
// ========================================

/// EN: Auth state enumeration
/// KO: 인증 상태 열거형
enum AuthState { initial, authenticated, unauthenticated }

/// EN: Auth state notifier for managing authentication
/// KO: 인증 관리를 위한 인증 상태 노티파이어
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._secureStorage) : super(AuthState.initial);

  final SecureStorage _secureStorage;

  /// EN: Check authentication status on app start.
  /// EN: Presence of both tokens is sufficient — the API interceptor handles
  /// EN: access-token refresh on 401/403 transparently. Gating on the stored
  /// EN: access-token expiry timestamp would incorrectly log the user out
  /// EN: whenever the short-lived access token expires while the refresh token
  /// EN: is still valid (which is the normal idle state between app launches).
  /// KO: 앱 시작 시 인증 상태 확인.
  /// KO: 두 토큰이 모두 존재하면 인증됨으로 처리합니다. API 인터셉터가
  /// KO: 401/403 응답 시 액세스 토큰을 투명하게 갱신합니다.
  /// KO: 저장된 액세스 토큰 만료 시간을 기준으로 판단하면 리프레시 토큰이
  /// KO: 유효한 상태에서도 세션이 조기 종료되는 문제가 발생합니다.
  Future<void> checkAuthStatus() async {
    final hasTokens = await _secureStorage.hasValidTokens();
    state = hasTokens ? AuthState.authenticated : AuthState.unauthenticated;
  }

  /// EN: Set authenticated state
  /// KO: 인증됨 상태 설정
  void setAuthenticated() {
    state = AuthState.authenticated;
  }

  /// EN: Set unauthenticated state
  /// KO: 인증되지 않음 상태 설정
  void setUnauthenticated() {
    state = AuthState.unauthenticated;
  }

  /// EN: Logout - clear tokens and set unauthenticated
  /// KO: 로그아웃 - 토큰 삭제 및 인증되지 않음 설정
  Future<void> logout() async {
    await _secureStorage.clearTokens();
    state = AuthState.unauthenticated;
  }
}

/// EN: Auth state notifier provider
/// KO: 인증 상태 노티파이어 프로바이더
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthStateNotifier(secureStorage);
});

/// EN: Check if user is authenticated
/// KO: 사용자 인증 여부 확인
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider) == AuthState.authenticated;
});
