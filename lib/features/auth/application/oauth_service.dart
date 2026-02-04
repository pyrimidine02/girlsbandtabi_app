/// EN: OAuth launch service using configured authorization URLs.
/// KO: 설정된 인가 URL을 사용하는 OAuth 실행 서비스.
library;

import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/error/failure.dart';
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
  AuthOAuthService({AppConfig? config, UrlLauncher? launcher})
    : _config = config ?? AppConfig.instance,
      _launcher = launcher ?? DefaultUrlLauncher();

  final AppConfig _config;
  final UrlLauncher _launcher;

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

    if (!await _launcher.canLaunch(uri)) {
      return Result.failure(
        const NetworkFailure('Cannot launch OAuth URL', code: 'launch_failed'),
      );
    }

    await _launcher.launch(uri);
    return const Result.success(null);
  }
}
