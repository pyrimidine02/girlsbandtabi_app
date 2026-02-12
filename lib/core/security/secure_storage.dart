/// EN: Secure storage for sensitive data like tokens
/// KO: 토큰과 같은 민감한 데이터를 위한 보안 저장소
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// EN: Keys for secure storage
/// KO: 보안 저장소 키
class SecureStorageKeys {
  SecureStorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String tokenExpiry = 'token_expiry';
  static const String verificationKeyId = 'verification_key_id';
  static const String verificationDeviceId = 'verification_device_id';
  static const String verificationPrivateJwk = 'verification_private_jwk';
  static const String verificationKeyRegisteredAt =
      'verification_key_registered_at';
}

/// EN: Wrapper for FlutterSecureStorage with typed methods
/// KO: 타입화된 메서드를 제공하는 FlutterSecureStorage 래퍼
class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  // ========================================
  // EN: Token Management
  // KO: 토큰 관리
  // ========================================

  /// EN: Save access token
  /// KO: 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: SecureStorageKeys.accessToken, value: token);
  }

  /// EN: Get access token
  /// KO: 액세스 토큰 조회
  Future<String?> getAccessToken() async {
    return _storage.read(key: SecureStorageKeys.accessToken);
  }

  /// EN: Delete access token
  /// KO: 액세스 토큰 삭제
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: SecureStorageKeys.accessToken);
  }

  /// EN: Save refresh token
  /// KO: 리프레시 토큰 저장
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: SecureStorageKeys.refreshToken, value: token);
  }

  /// EN: Get refresh token
  /// KO: 리프레시 토큰 조회
  Future<String?> getRefreshToken() async {
    return _storage.read(key: SecureStorageKeys.refreshToken);
  }

  /// EN: Delete refresh token
  /// KO: 리프레시 토큰 삭제
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: SecureStorageKeys.refreshToken);
  }

  /// EN: Save both tokens at once
  /// KO: 두 토큰을 한번에 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// EN: Delete all tokens (logout)
  /// KO: 모든 토큰 삭제 (로그아웃)
  Future<void> clearTokens() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
      _storage.delete(key: SecureStorageKeys.tokenExpiry),
    ]);
  }

  /// EN: Check if user has valid tokens
  /// KO: 유효한 토큰이 있는지 확인
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // ========================================
  // EN: Token Expiry Management
  // KO: 토큰 만료 관리
  // ========================================

  /// EN: Save token expiry timestamp
  /// KO: 토큰 만료 타임스탬프 저장
  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _storage.write(
      key: SecureStorageKeys.tokenExpiry,
      value: expiry.toIso8601String(),
    );
  }

  /// EN: Get token expiry timestamp
  /// KO: 토큰 만료 타임스탬프 조회
  Future<DateTime?> getTokenExpiry() async {
    final value = await _storage.read(key: SecureStorageKeys.tokenExpiry);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// EN: Check if token is expired
  /// KO: 토큰이 만료되었는지 확인
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    // EN: If expiry is unknown, treat token as valid and rely on refresh/401.
    // KO: 만료 시간이 없으면 유효하다고 간주하고 갱신/401 처리에 맡깁니다.
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  // ========================================
  // EN: User ID Management
  // KO: 사용자 ID 관리
  // ========================================

  /// EN: Save user ID
  /// KO: 사용자 ID 저장
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: SecureStorageKeys.userId, value: userId);
  }

  /// EN: Get user ID
  /// KO: 사용자 ID 조회
  Future<String?> getUserId() async {
    return _storage.read(key: SecureStorageKeys.userId);
  }

  /// EN: Delete user ID
  /// KO: 사용자 ID 삭제
  Future<void> deleteUserId() async {
    await _storage.delete(key: SecureStorageKeys.userId);
  }

  // ========================================
  // EN: Verification device key management
  // KO: 인증 디바이스 키 관리
  // ========================================

  /// EN: Save verification key ID.
  /// KO: 인증 키 ID 저장.
  Future<void> saveVerificationKeyId(String keyId) async {
    await _storage.write(
      key: SecureStorageKeys.verificationKeyId,
      value: keyId,
    );
  }

  /// EN: Get verification key ID.
  /// KO: 인증 키 ID 조회.
  Future<String?> getVerificationKeyId() async {
    return _storage.read(key: SecureStorageKeys.verificationKeyId);
  }

  /// EN: Save device ID for verification.
  /// KO: 인증용 디바이스 ID 저장.
  Future<void> saveVerificationDeviceId(String deviceId) async {
    await _storage.write(
      key: SecureStorageKeys.verificationDeviceId,
      value: deviceId,
    );
  }

  /// EN: Get device ID for verification.
  /// KO: 인증용 디바이스 ID 조회.
  Future<String?> getVerificationDeviceId() async {
    return _storage.read(key: SecureStorageKeys.verificationDeviceId);
  }

  /// EN: Save verification private JWK (JSON string).
  /// KO: 인증용 개인키 JWK(JSON 문자열) 저장.
  Future<void> saveVerificationPrivateJwk(String jwkJson) async {
    await _storage.write(
      key: SecureStorageKeys.verificationPrivateJwk,
      value: jwkJson,
    );
  }

  /// EN: Get verification private JWK (JSON string).
  /// KO: 인증용 개인키 JWK(JSON 문자열) 조회.
  Future<String?> getVerificationPrivateJwk() async {
    return _storage.read(key: SecureStorageKeys.verificationPrivateJwk);
  }

  /// EN: Save verification key registration timestamp.
  /// KO: 인증 키 등록 시간 저장.
  Future<void> saveVerificationKeyRegisteredAt(DateTime registeredAt) async {
    await _storage.write(
      key: SecureStorageKeys.verificationKeyRegisteredAt,
      value: registeredAt.toIso8601String(),
    );
  }

  /// EN: Get verification key registration timestamp.
  /// KO: 인증 키 등록 시간 조회.
  Future<DateTime?> getVerificationKeyRegisteredAt() async {
    final value = await _storage.read(
      key: SecureStorageKeys.verificationKeyRegisteredAt,
    );
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// EN: Clear verification key material.
  /// KO: 인증 키 자료 삭제.
  Future<void> clearVerificationKeys() async {
    await Future.wait([
      _storage.delete(key: SecureStorageKeys.verificationKeyId),
      _storage.delete(key: SecureStorageKeys.verificationDeviceId),
      _storage.delete(key: SecureStorageKeys.verificationPrivateJwk),
      _storage.delete(key: SecureStorageKeys.verificationKeyRegisteredAt),
    ]);
  }

  // ========================================
  // EN: Generic Methods
  // KO: 제네릭 메서드
  // ========================================

  /// EN: Write value to secure storage
  /// KO: 보안 저장소에 값 쓰기
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// EN: Read value from secure storage
  /// KO: 보안 저장소에서 값 읽기
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  /// EN: Delete value from secure storage
  /// KO: 보안 저장소에서 값 삭제
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// EN: Clear all data from secure storage
  /// KO: 보안 저장소의 모든 데이터 삭제
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// EN: Check if key exists in secure storage
  /// KO: 보안 저장소에 키가 존재하는지 확인
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}
