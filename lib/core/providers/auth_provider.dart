import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'core_providers.dart';

part 'auth_provider.g.dart';

enum AuthState { initial, authenticated, unauthenticated }

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    return AuthState.initial;
  }

  Future<void> checkAuthStatus() async {
    final hasTokens = await ref.read(secureStorageProvider).hasValidTokens();
    if (!hasTokens) {
      state = AuthState.unauthenticated;
      return;
    }
    final isExpired = await ref.read(secureStorageProvider).isTokenExpired();
    state = isExpired ? AuthState.unauthenticated : AuthState.authenticated;
  }

  void setAuthenticated() {
    state = AuthState.authenticated;
  }

  void setUnauthenticated() {
    state = AuthState.unauthenticated;
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearTokens();
    state = AuthState.unauthenticated;
  }
}

@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authProvider) == AuthState.authenticated;
}
