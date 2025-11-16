import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/network_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';
import '../usecases/get_current_user_usecase.dart';
import '../usecases/login_usecase.dart';
import '../usecases/logout_usecase.dart';
import '../usecases/register_usecase.dart';

/// EN: Provider for secure storage instance
/// KO: 보안 저장소 인스턴스를 위한 프로바이더
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// EN: Provider for shared preferences instance
/// KO: 공유 환경설정 인스턴스를 위한 프로바이더
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

/// EN: Provider for network client instance
/// KO: 네트워크 클라이언트 인스턴스를 위한 프로바이더
final networkClientProvider = Provider<NetworkClient>((ref) {
  throw UnimplementedError('NetworkClient must be initialized');
});

/// EN: Provider for auth local data source
/// KO: 인증 로컬 데이터 소스를 위한 프로바이더
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    secureStorage: ref.watch(secureStorageProvider),
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

/// EN: Provider for auth remote data source
/// KO: 인증 원격 데이터 소스를 위한 프로바이더
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    networkClient: ref.watch(networkClientProvider),
  );
});

/// EN: Provider for auth repository
/// KO: 인증 리포지터리를 위한 프로바이더
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

/// EN: Provider for login use case
/// KO: 로그인 유스케이스를 위한 프로바이더
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// EN: Provider for register use case
/// KO: 등록 유스케이스를 위한 프로바이더
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// EN: Provider for logout use case
/// KO: 로그아웃 유스케이스를 위한 프로바이더
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// EN: Provider for get current user use case
/// KO: 현재 사용자 가져오기 유스케이스를 위한 프로바이더
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// EN: Provider for checking authentication status
/// KO: 인증 상태 확인을 위한 프로바이더
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final result = await authRepository.isAuthenticated();
  
  return switch (result) {
    Success(:final data) => data,
    ResultFailure() => false, // EN: Return false on error / KO: 오류시 false 반환
  };
});

/// EN: Provider for current user data
/// KO: 현재 사용자 데이터를 위한 프로바이더
final currentUserProvider = FutureProvider((ref) async {
  final getCurrentUser = ref.watch(getCurrentUserUseCaseProvider);
  final result = await getCurrentUser();
  
  return switch (result) {
    Success(:final data) => data,
    ResultFailure(:final failure) => throw failure, // EN: Throw failure to trigger error state / KO: 에러 상태를 트리거하기 위해 실패 던지기
  };
});

/// EN: Provider for auth controller state notifier
/// KO: 인증 컨트롤러 상태 알림자를 위한 프로바이더
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});

/// EN: Provider that ensures the auth controller checks the current session on startup.
/// KO: 시작 시 인증 컨트롤러가 현재 세션을 확인하도록 보장하는 프로바이더입니다.
