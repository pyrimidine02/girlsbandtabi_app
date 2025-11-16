import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/network/api_client.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) => UserService());

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authService: ref.read(authServiceProvider),
    userService: ref.read(userServiceProvider),
  );
});

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? currentUser;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.currentUser,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? currentUser,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserService _userService;

  AuthNotifier({
    required AuthService authService,
    required UserService userService,
  }) : _authService = authService,
       _userService = userService,
       super(const AuthState()) {
    _checkAuthStatus();
  }

  // Check initial auth status
  Future<void> _checkAuthStatus() async {
        state = state.copyWith(isLoading: true);
    
    try {
      // Add a small delay to show splash screen briefly
      await Future.delayed(const Duration(milliseconds: 1500));
      
            final isAuthenticated = await _authService.isAuthenticated();
            
      if (isAuthenticated) {
                final user = await _userService.getCurrentUser();
                state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: user,
        );
              } else {
                state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
              }
    } catch (e) {
            state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _mapErrorMessage(e),
      );
    }
  }

  String _mapErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }

  // Login
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final loginRequest = LoginRequest(username: username, password: password);
      await _authService.login(loginRequest);
      
      // Fetch user profile after successful login
      final user = await _userService.getCurrentUser();
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentUser: user,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _mapErrorMessage(e),
      );
      return false;
    }
  }

  // Register
  Future<bool> register(String username, String password, String nickname) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final registerRequest = RegisterRequest(
        username: username,
        password: password,
        nickname: nickname,
      );
      await _authService.register(registerRequest);
      
      // Fetch user profile after successful registration
      final user = await _userService.getCurrentUser();
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentUser: user,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _mapErrorMessage(e),
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.logout();
    } catch (e) {
      // Even if logout request fails, clear local state
    }
    
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: false,
      currentUser: null,
    );
  }

  // Update user profile
  Future<bool> updateProfile({String? displayName, String? avatarUrl}) async {
    if (state.currentUser == null) return false;
    
    try {
      final updatedUser = await _userService.updateCurrentUser(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      
      state = state.copyWith(currentUser: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(error: _mapErrorMessage(e));
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;
    
    try {
      final user = await _userService.getCurrentUser();
      state = state.copyWith(currentUser: user);
    } catch (e) {
      // If refresh fails, user might need to re-login
      state = state.copyWith(
        isAuthenticated: false,
        currentUser: null,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
