/// EN: Application configuration with environment-specific settings
/// KO: 환경별 설정을 포함한 앱 구성
library;

import 'package:flutter/foundation.dart';

/// EN: Environment types for the application
/// KO: 앱 환경 타입
enum Environment { development, staging, production }

const String _developmentBaseUrlOverride = String.fromEnvironment(
  'DEVELOPMENT_BASE_URL',
  defaultValue: '',
);
const String _stagingBaseUrl = String.fromEnvironment(
  'STAGING_BASE_URL',
  defaultValue: 'https://staging-api.pyrimidines.org',
);
const String _productionBaseUrl = String.fromEnvironment(
  'PRODUCTION_BASE_URL',
  defaultValue: 'https://api.pyrimidines.org',
);

/// EN: Application configuration singleton
/// KO: 앱 구성 싱글톤
class AppConfig {
  AppConfig._();

  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();

  late Environment _environment;
  late String _baseUrl;
  late String _projectId;
  String? _projectCode;
  late Map<String, String> _oauthAuthorizeUrls;

  /// EN: Initialize configuration based on environment
  /// KO: 환경에 따른 구성 초기화
  void init({
    Environment environment = Environment.development,
    String? baseUrl,
    String? projectId,
    String? projectCode,
    Map<String, String>? oauthAuthorizeUrls,
  }) {
    _environment = environment;
    _baseUrl = baseUrl ?? _getDefaultBaseUrl(environment);
    _projectId = projectId ?? _getDefaultProjectId(environment);
    _projectCode = projectCode;
    _oauthAuthorizeUrls = oauthAuthorizeUrls ?? <String, String>{};
  }

  Environment get environment => _environment;
  String get baseUrl => _baseUrl;
  String get projectId => _projectId;
  String? get projectCode => _projectCode;
  Map<String, String> get oauthAuthorizeUrls => _oauthAuthorizeUrls;

  /// EN: Check if running in debug mode
  /// KO: 디버그 모드 여부 확인
  bool get isDebug => kDebugMode;

  /// EN: Check if running in production
  /// KO: 프로덕션 환경 여부 확인
  bool get isProduction => _environment == Environment.production;

  String _getDefaultBaseUrl(Environment env) {
    return switch (env) {
      Environment.development => _resolveDevelopmentBaseUrl(),
      Environment.staging => _stagingBaseUrl,
      Environment.production => _productionBaseUrl,
    };
  }

  String _resolveDevelopmentBaseUrl() {
    if (_developmentBaseUrlOverride.trim().isNotEmpty) {
      return _developmentBaseUrlOverride.trim();
    }
    // EN: Allow local HTTP only for debug/runtime development.
    // KO: 로컬 HTTP는 디버그/개발 실행에서만 허용합니다.
    if (kDebugMode) {
      return (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
          ? 'http://10.0.2.2:8080'
          : 'http://localhost:8080';
    }
    // EN: In non-debug builds, avoid plaintext fallback.
    // KO: 비디버그 빌드에서는 평문 HTTP 폴백을 피합니다.
    return _stagingBaseUrl;
  }

  String _getDefaultProjectId(Environment env) {
    return switch (env) {
      Environment.development => '10000000-0000-0000-0000-000000000001',
      Environment.staging => '10000000-0000-0000-0000-000000000001',
      Environment.production => '10000000-0000-0000-0000-000000000001',
    };
  }
}
