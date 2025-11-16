import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/user.dart';
import '../usecases/get_current_user_usecase.dart';
import '../usecases/login_usecase.dart';
import '../usecases/logout_usecase.dart';
import '../usecases/register_usecase.dart';

part 'auth_controller.freezed.dart';

/// EN: Authentication state representation
/// KO: 인증 상태 표현
@freezed
class AuthState with _$AuthState {
  /// EN: Initial state - checking authentication status
  /// KO: 초기 상태 - 인증 상태 확인 중
  const factory AuthState.initial() = _Initial;
  
  /// EN: Loading state during authentication operations
  /// KO: 인증 작업 중 로딩 상태
  const factory AuthState.loading() = _Loading;
  
  /// EN: Authenticated state with user data
  /// KO: 사용자 데이터와 함께하는 인증 상태
  const factory AuthState.authenticated({
    required User user,
  }) = _Authenticated;
  
  /// EN: Unauthenticated state
  /// KO: 비인증 상태
  const factory AuthState.unauthenticated() = _Unauthenticated;
  
  /// EN: Error state with failure information
  /// KO: 실패 정보와 함께하는 오류 상태
  const factory AuthState.error({
    required Failure failure,
  }) = _Error;
}

/// EN: Authentication controller managing auth state and operations
/// KO: 인증 상태 및 작업을 관리하는 인증 컨트롤러
class AuthController extends StateNotifier<AuthState> {
  /// EN: Creates auth controller with use cases
  /// KO: 유스케이스와 함께 인증 컨트롤러 생성
  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState.initial());

  /// EN: Login use case for authentication
  /// KO: 인증을 위한 로그인 유스케이스
  final LoginUseCase loginUseCase;

  /// EN: Register use case for user registration
  /// KO: 사용자 등록을 위한 등록 유스케이스
  final RegisterUseCase registerUseCase;

  /// EN: Logout use case for signing out
  /// KO: 로그아웃을 위한 로그아웃 유스케이스
  final LogoutUseCase logoutUseCase;

  /// EN: Get current user use case for fetching user data
  /// KO: 사용자 데이터 가져오기를 위한 현재 사용자 유스케이스
  final GetCurrentUserUseCase getCurrentUserUseCase;

  /// EN: Check initial authentication status
  /// KO: 초기 인증 상태 확인
  Future<void> checkAuthStatus() async {
    if (state != const AuthState.initial()) return;

    state = const AuthState.loading();

    final result = await getCurrentUserUseCase();
    
    state = switch (result) {
      Success(:final data) => AuthState.authenticated(user: data),
      ResultFailure() => const AuthState.unauthenticated(),
    };
  }

  /// EN: Login with email and password
  /// KO: 이메일과 비밀번호로 로그인
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AuthState.loading();

    final credentials = LoginCredentials(username: username, password: password);
    final result = await loginUseCase(credentials);

    state = await switch (result) {
      Success() => _handleSuccessfulAuth(),
      ResultFailure(:final failure) => AuthState.error(failure: failure),
    };
  }

  /// EN: Register new user account
  /// KO: 새 사용자 계정 등록
  Future<void> register({
    required String username,
    required String password,
    required String nickname,
  }) async {
    state = const AuthState.loading();

    final credentials = RegisterCredentials(
      username: username,
      password: password,
      nickname: nickname,
    );
    
    final result = await registerUseCase(credentials);

    state = await switch (result) {
      Success() => _handleSuccessfulAuth(),
      ResultFailure(:final failure) => AuthState.error(failure: failure),
    };
  }

  /// EN: Logout current user
  /// KO: 현재 사용자 로그아웃
  Future<void> logout() async {
    state = const AuthState.loading();

    final result = await logoutUseCase();

    state = switch (result) {
      Success() => const AuthState.unauthenticated(),
      ResultFailure(:final failure) => AuthState.error(failure: failure),
    };
  }

  /// EN: Refresh current user data
  /// KO: 현재 사용자 데이터 새로 고침
  Future<void> refreshUser() async {
    final result = await getCurrentUserUseCase();

    state = switch (result) {
      Success(:final data) => AuthState.authenticated(user: data),
      ResultFailure(:final failure) => AuthState.error(failure: failure),
    };
  }

  /// EN: Clear error state
  /// KO: 오류 상태 지우기
  void clearError() {
    if (state is _Error) {
      state = const AuthState.unauthenticated();
    }
  }

  /// EN: Handle successful authentication by getting user data
  /// KO: 사용자 데이터를 가져와 성공적인 인증 처리
  Future<AuthState> _handleSuccessfulAuth() async {
    final userResult = await getCurrentUserUseCase();
    
    return switch (userResult) {
      Success(:final data) => AuthState.authenticated(user: data),
      ResultFailure(:final failure) => AuthState.error(failure: failure),
    };
  }

  /// EN: Check if user is currently authenticated
  /// KO: 사용자가 현재 인증되었는지 확인
  bool get isAuthenticated => state is _Authenticated;

  /// EN: Check if auth operation is in progress
  /// KO: 인증 작업이 진행 중인지 확인
  bool get isLoading => state is _Loading;

  /// EN: Get current authenticated user (null if not authenticated)
  /// KO: 현재 인증된 사용자 가져오기 (인증되지 않은 경우 null)
  User? get currentUser => switch (state) {
    _Authenticated(:final user) => user,
    _ => null,
  };

  /// EN: Get current error (null if no error)
  /// KO: 현재 오류 가져오기 (오류가 없는 경우 null)
  Failure? get currentError => switch (state) {
    _Error(:final failure) => failure,
    _ => null,
  };
}
