/// EN: OAuth launch service using configured authorization URLs.
/// KO: 설정된 인가 URL을 사용하는 OAuth 실행 서비스.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/error/failure.dart';
import '../../../core/security/secure_storage.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/oauth_provider.dart';

/// EN: URL launcher abstraction for testability.
/// KO: 테스트 가능성을 위한 URL 런처 추상화.
abstract class UrlLauncher {
  Future<bool> canLaunch(Uri uri);
  Future<bool> launch(Uri uri);
}

class DefaultUrlLauncher implements UrlLauncher {
  @override
  Future<bool> canLaunch(Uri uri) => canLaunchUrl(uri);

  @override
  Future<bool> launch(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

// EN: X (Twitter) OAuth 2.0 PKCE constants.
//     TWITTER_CLIENT_ID defaults to the registered public client ID;
//     override at build time via --dart-define=TWITTER_CLIENT_ID=<x-client-id>.
//     redirectUri MUST match the value registered in the X Developer Portal
//     and configured as a Universal Link / App Link on the backend.
// KO: X (Twitter) OAuth 2.0 PKCE 상수.
//     TWITTER_CLIENT_ID는 등록된 공개 클라이언트 ID가 기본값입니다.
//     빌드 시 --dart-define=TWITTER_CLIENT_ID=<x-client-id>로 재정의 가능합니다.
//     redirectUri는 X 개발자 포털과 백엔드에 등록된 값과 정확히 일치해야 합니다.
const String _twitterClientId = String.fromEnvironment(
  'TWITTER_CLIENT_ID',
  defaultValue: 'LWI2cmZCYUM0WHBKeFB0Nnl6Szc6MTpjaQ',
);
const String _twitterRedirectUri = 'https://api.noraneko.cc/oauth/x/callback';
const String _twitterAuthBaseUrl = 'https://x.com/i/oauth2/authorize';
const String _twitterScope = 'tweet.read users.read offline.access';

/// EN: OAuth service for launching external login flows.
/// KO: 외부 로그인 플로우 실행을 위한 OAuth 서비스.
class AuthOAuthService {
  AuthOAuthService({
    AppConfig? config,
    UrlLauncher? launcher,
    SecureStorage? secureStorage,
  })
    : _config = config ?? AppConfig.instance,
      _launcher = launcher ?? DefaultUrlLauncher(),
      _secureStorage = secureStorage ?? SecureStorage();

  final AppConfig _config;
  final UrlLauncher _launcher;
  final SecureStorage _secureStorage;

  /// EN: Check if provider is configured.
  /// KO: 제공자가 설정되어 있는지 확인.
  bool isConfigured(OAuthProvider provider) {
    return _config.oauthAuthorizeUrls.containsKey(provider.id);
  }

  /// EN: Launch OAuth authorization flow.
  /// KO: OAuth 인가 플로우 실행.
  Future<Result<void>> launch(OAuthProvider provider) async {
    final url = _config.oauthAuthorizeUrls[provider.id];
    if (url == null || url.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          'OAuth provider not configured',
          code: 'oauth_not_configured',
        ),
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return Result.failure(
        const ValidationFailure('Invalid OAuth URL', code: 'invalid_oauth_url'),
      );
    }

    final state = _generateStateNonce();
    await _secureStorage.saveOAuthPendingState(
      state: state,
      providerId: provider.id,
    );

    final authorizationUri = _appendState(uri, state);
    if (!await _launcher.canLaunch(authorizationUri)) {
      return Result.failure(
        const NetworkFailure('Cannot launch OAuth URL', code: 'launch_failed'),
      );
    }

    final launched = await _launcher.launch(authorizationUri);
    if (!launched) {
      return Result.failure(
        const NetworkFailure('Cannot launch OAuth URL', code: 'launch_failed'),
      );
    }
    return const Result.success(null);
  }

  /// EN: Launch X (Twitter) OAuth 2.0 + PKCE authorization flow.
  ///     Generates code_verifier/code_challenge, persists the verifier in
  ///     SecureStorage, then opens the X authorization page in the browser.
  ///     The app receives the callback via girlsbandtabi://oauth/callback.
  /// KO: X (Twitter) OAuth 2.0 + PKCE 인가 플로우를 실행합니다.
  ///     code_verifier/code_challenge를 생성하고, verifier를 SecureStorage에
  ///     저장한 뒤 브라우저에서 X 인가 페이지를 엽니다.
  ///     앱은 girlsbandtabi://oauth/callback으로 콜백을 수신합니다.
  Future<Result<void>> launchTwitterPkce() async {
    if (_twitterClientId.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          'Twitter client ID not configured. '
          'Set TWITTER_CLIENT_ID via --dart-define.',
          code: 'twitter_client_id_missing',
        ),
      );
    }

    // EN: Generate PKCE pair (verifier: 64 random bytes → base64url, challenge: SHA256).
    // KO: PKCE 쌍 생성 (verifier: 64바이트 랜덤 → base64url, challenge: SHA256).
    final verifier = _generateCodeVerifier();
    final challenge = _buildCodeChallenge(verifier);

    // EN: Persist verifier — retrieved by completeTwitterLogin() after callback.
    // KO: verifier 저장 — 콜백 수신 후 completeTwitterLogin()이 읽어갑니다.
    await _secureStorage.saveTwitterCodeVerifier(verifier);

    final state = _generateStateNonce();
    await _secureStorage.saveOAuthPendingState(
      state: state,
      providerId: OAuthProvider.twitter.id,
    );

    final uri = Uri.parse(_twitterAuthBaseUrl).replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': _twitterClientId,
        'redirect_uri': _twitterRedirectUri,
        'scope': _twitterScope,
        'state': state,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
      },
    );

    if (!await _launcher.canLaunch(uri)) {
      return Result.failure(
        const NetworkFailure(
          'Cannot launch Twitter auth URL',
          code: 'launch_failed',
        ),
      );
    }

    final launched = await _launcher.launch(uri);
    if (!launched) {
      return Result.failure(
        const NetworkFailure(
          'Failed to launch Twitter auth URL',
          code: 'launch_failed',
        ),
      );
    }
    return const Result.success(null);
  }

  /// EN: Validate callback `state` against the stored nonce and consume it.
  /// KO: 콜백 `state`를 저장된 nonce와 비교 검증하고 즉시 소모합니다.
  Future<Result<void>> validateAndConsumeState({
    required OAuthProvider provider,
    String? callbackState,
  }) async {
    final expectedState = await _secureStorage.getOAuthPendingState();
    final expectedProvider = await _secureStorage.getOAuthPendingProvider();
    await _secureStorage.clearOAuthPendingState();

    if (expectedState == null || expectedState.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure(
          'Missing OAuth state in secure storage',
          code: 'oauth_state_missing',
        ),
      );
    }

    if (expectedProvider != null &&
        expectedProvider.isNotEmpty &&
        expectedProvider != provider.id) {
      return Result.failure(
        const ValidationFailure(
          'OAuth provider mismatch',
          code: 'oauth_provider_mismatch',
        ),
      );
    }

    final receivedState = callbackState?.trim() ?? '';
    if (receivedState.isEmpty) {
      return Result.failure(
        const ValidationFailure(
          'OAuth callback state missing',
          code: 'oauth_state_missing',
        ),
      );
    }
    if (receivedState != expectedState) {
      return Result.failure(
        const ValidationFailure(
          'OAuth callback state mismatch',
          code: 'oauth_state_mismatch',
        ),
      );
    }
    return const Result.success(null);
  }

  String _generateStateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  Uri _appendState(Uri uri, String state) {
    final query = <String, String>{...uri.queryParameters, 'state': state};
    return uri.replace(queryParameters: query);
  }

  /// EN: Generate a cryptographically random PKCE code_verifier (64 random bytes → base64url, no padding).
  /// KO: 암호학적으로 안전한 PKCE code_verifier를 생성합니다 (64바이트 랜덤 → base64url, 패딩 없음).
  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = Uint8List(64);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// EN: Derive PKCE code_challenge = BASE64URL(SHA256(verifier)), no padding.
  /// KO: PKCE code_challenge = BASE64URL(SHA256(verifier)) 계산, 패딩 없음.
  String _buildCodeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
