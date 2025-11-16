import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiClient _api = ApiClient.instance;

  Future<AuthResponse> login(LoginRequest request) async {
    final envelope = await _api.post(
      ApiConstants.login,
      data: {
        'username': request.email,
        'password': request.password,
      },
    );

    final payload = envelope.requireDataAsMap();
    final auth = AuthResponse.fromJson(payload);
    await _storeTokens(auth);
    return auth;
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final envelope = await _api.post(
      ApiConstants.register,
      data: {
        'username': request.email,
        'password': request.password,
        'nickname': request.displayName,
        'termsAcceptedAt': DateTime.now().toIso8601String(),
        'privacyAcceptedAt': DateTime.now().toIso8601String(),
        'termsVersion': 'v1.0',
        'privacyVersion': 'v1.0',
      },
    );

    final payload = envelope.requireDataAsMap();
    final auth = AuthResponse.fromJson(payload);
    await _storeTokens(auth);
    return auth;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      await _api.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } catch (_) {
      // Best-effort logout; ignore network failures.
    }
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: 'access_token');
  }

  Future<AuthResponse?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      final envelope = await _api.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final payload = envelope.requireDataAsMap();
      final auth = AuthResponse.fromJson(payload);
      await _storeTokens(auth);
      return auth;
    } catch (_) {
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      return null;
    }
  }

  Future<AuthResponse> handleOAuth2Callback(String provider, String code) async {
    final envelope = await _api.get(
      ApiConstants.oauth2Callback(provider),
      queryParameters: {'code': code},
      options: Options(extra: {'skipAuth': true}),
    );

    final payload = envelope.requireDataAsMap();
    final auth = AuthResponse.fromJson(payload);
    await _storeTokens(auth);
    return auth;
  }

  Future<void> _storeTokens(AuthResponse auth) async {
    await _secureStorage.write(key: 'access_token', value: auth.accessToken);
    await _secureStorage.write(key: 'refresh_token', value: auth.refreshToken);
  }
}
