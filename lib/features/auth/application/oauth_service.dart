/// EN: OAuth launch service using configured authorization URLs.
/// KO: 설정된 인가 URL을 사용하는 OAuth 실행 서비스.
library;

import 'dart:convert';
import 'dart:math';

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
}
