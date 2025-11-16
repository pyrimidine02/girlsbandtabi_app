import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../models/user_model.dart';

/// EN: Abstract interface for local authentication data source
/// KO: 로컬 인증 데이터 소스를 위한 추상 인터페이스
abstract interface class AuthLocalDataSource {
  /// EN: Store authentication tokens securely
  /// KO: 인증 토큰을 안전하게 저장
  Future<Result<void>> storeTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// EN: Retrieve stored access token
  /// KO: 저장된 액세스 토큰 검색
  Future<Result<String?>> getAccessToken();

  /// EN: Retrieve stored refresh token
  /// KO: 저장된 리프레시 토큰 검색
  Future<Result<String?>> getRefreshToken();

  /// EN: Clear all stored authentication tokens
  /// KO: 저장된 모든 인증 토큰 지우기
  Future<Result<void>> clearTokens();

  /// EN: Cache user profile locally
  /// KO: 사용자 프로필을 로컬에 캐시
  Future<Result<void>> cacheUser(UserModel user);

  /// EN: Retrieve cached user profile
  /// KO: 캐시된 사용자 프로필 검색
  Future<Result<UserModel?>> getCachedUser();

  /// EN: Clear cached user data
  /// KO: 캐시된 사용자 데이터 지우기
  Future<Result<void>> clearCachedUser();

  /// EN: Check if user is logged in (has valid tokens)
  /// KO: 사용자가 로그인되어 있는지 확인 (유효한 토큰 보유)
  Future<Result<bool>> isLoggedIn();

  /// EN: Store app preferences
  /// KO: 앱 환경설정 저장
  Future<Result<void>> storePreference(String key, String value);

  /// EN: Retrieve app preference
  /// KO: 앱 환경설정 검색
  Future<Result<String?>> getPreference(String key);

  /// EN: Clear all app preferences
  /// KO: 모든 앱 환경설정 지우기
  Future<Result<void>> clearPreferences();
}

/// EN: Implementation of local authentication data source
/// KO: 로컬 인증 데이터 소스 구현
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// EN: Creates auth local data source with storage dependencies
  /// KO: 저장소 의존성을 가진 인증 로컬 데이터 소스 생성
  const AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  /// EN: Secure storage for sensitive data (tokens)
  /// KO: 민감한 데이터(토큰)를 위한 보안 저장소
  final FlutterSecureStorage secureStorage;

  /// EN: Shared preferences for non-sensitive data
  /// KO: 민감하지 않은 데이터를 위한 공유 환경설정
  final SharedPreferences sharedPreferences;

  // EN: Storage keys
  // KO: 저장소 키
  static const String _accessTokenKey = 'auth_access_token';
  static const String _legacyAccessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _legacyRefreshTokenKey = 'refresh_token';
  static const String _userCacheKey = 'auth_cached_user';

  @override
  Future<Result<void>> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        secureStorage.write(key: _accessTokenKey, value: accessToken),
        secureStorage.write(key: _legacyAccessTokenKey, value: accessToken),
        secureStorage.write(key: _refreshTokenKey, value: refreshToken),
        secureStorage.write(key: _legacyRefreshTokenKey, value: refreshToken),
      ]);
      return const Success(null);
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to store authentication tokens: ${e.toString()}',
        code: 'TOKEN_STORE_ERROR',
      ));
    }
  }

  @override
  Future<Result<String?>> getAccessToken() async {
    try {
      final token = await secureStorage.read(key: _accessTokenKey);
      if (token != null && token.isNotEmpty) {
        return Success(token);
      }
      final legacyToken = await secureStorage.read(key: _legacyAccessTokenKey);
      return Success(legacyToken);
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to retrieve access token: ${e.toString()}',
        code: 'TOKEN_RETRIEVE_ERROR',
      ));
    }
  }

  @override
  Future<Result<String?>> getRefreshToken() async {
    try {
      final token = await secureStorage.read(key: _refreshTokenKey);
      if (token != null && token.isNotEmpty) {
        return Success(token);
      }
      final legacyToken = await secureStorage.read(key: _legacyRefreshTokenKey);
      return Success(legacyToken);
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to retrieve refresh token: ${e.toString()}',
        code: 'TOKEN_RETRIEVE_ERROR',
      ));
    }
  }

  @override
  Future<Result<void>> clearTokens() async {
    try {
      await Future.wait([
        secureStorage.delete(key: _accessTokenKey),
        secureStorage.delete(key: _legacyAccessTokenKey),
        secureStorage.delete(key: _refreshTokenKey),
        secureStorage.delete(key: _legacyRefreshTokenKey),
      ]);
      return const Success(null);
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to clear authentication tokens: ${e.toString()}',
        code: 'TOKEN_CLEAR_ERROR',
      ));
    }
  }

  @override
  Future<Result<void>> cacheUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      final userString = userJson.toString(); // EN: Convert to string for storage / KO: 저장을 위해 문자열로 변환
      
      final success = await sharedPreferences.setString(_userCacheKey, userString);
      if (success) {
        return const Success(null);
      } else {
        return const ResultFailure(StorageFailure(
          message: 'Failed to cache user profile',
          code: 'USER_CACHE_ERROR',
        ));
      }
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to cache user profile: ${e.toString()}',
        code: 'USER_CACHE_ERROR',
      ));
    }
  }

  @override
  Future<Result<UserModel?>> getCachedUser() async {
    try {
      final userString = sharedPreferences.getString(_userCacheKey);
      if (userString == null) {
        return const Success(null);
      }

      // EN: Note: This is a simplified implementation. In a real app, you'd want to
      // use a proper JSON serialization library or store as JSON string
      // KO: 참고: 이것은 단순화된 구현입니다. 실제 앱에서는 적절한 JSON 직렬화 라이브러리를 사용하거나 JSON 문자열로 저장하고 싶을 것입니다
      
      return const Success(null); // EN: Placeholder - implement proper deserialization / KO: 자리 표시자 - 적절한 역직렬화 구현
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to retrieve cached user: ${e.toString()}',
        code: 'USER_CACHE_RETRIEVE_ERROR',
      ));
    }
  }

  @override
  Future<Result<void>> clearCachedUser() async {
    try {
      final success = await sharedPreferences.remove(_userCacheKey);
      if (success) {
        return const Success(null);
      } else {
        return const ResultFailure(StorageFailure(
          message: 'Failed to clear cached user',
          code: 'USER_CACHE_CLEAR_ERROR',
        ));
      }
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to clear cached user: ${e.toString()}',
        code: 'USER_CACHE_CLEAR_ERROR',
      ));
    }
  }

  @override
  Future<Result<bool>> isLoggedIn() async {
    try {
      final accessTokenResult = await getAccessToken();
      final refreshTokenResult = await getRefreshToken();

      return accessTokenResult.flatMap((accessToken) {
        return refreshTokenResult.map((refreshToken) {
          return accessToken != null && 
                 accessToken.isNotEmpty && 
                 refreshToken != null && 
                 refreshToken.isNotEmpty;
        });
      });
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to check login status: ${e.toString()}',
        code: 'LOGIN_STATUS_CHECK_ERROR',
      ));
    }
  }

  @override
  Future<Result<void>> storePreference(String key, String value) async {
    try {
      final success = await sharedPreferences.setString(key, value);
      if (success) {
        return const Success(null);
      } else {
        return ResultFailure(StorageFailure(
          message: 'Failed to store preference: $key',
          code: 'PREFERENCE_STORE_ERROR',
        ));
      }
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to store preference: ${e.toString()}',
        code: 'PREFERENCE_STORE_ERROR',
      ));
    }
  }

  @override
  Future<Result<String?>> getPreference(String key) async {
    try {
      final value = sharedPreferences.getString(key);
      return Success(value);
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to retrieve preference: ${e.toString()}',
        code: 'PREFERENCE_RETRIEVE_ERROR',
      ));
    }
  }

  @override
  Future<Result<void>> clearPreferences() async {
    try {
      final success = await sharedPreferences.clear();
      if (success) {
        return const Success(null);
      } else {
        return const ResultFailure(StorageFailure(
          message: 'Failed to clear preferences',
          code: 'PREFERENCE_CLEAR_ERROR',
        ));
      }
    } catch (e) {
      return ResultFailure(StorageFailure(
        message: 'Failed to clear preferences: ${e.toString()}',
        code: 'PREFERENCE_CLEAR_ERROR',
      ));
    }
  }
}
