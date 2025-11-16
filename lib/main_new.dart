import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/api_constants.dart';
import 'core/network/network_client.dart';
import 'features/auth/application/providers/auth_providers.dart';

/// EN: Application entry point with dependency injection setup
/// KO: 의존성 주입 설정을 포함한 애플리케이션 진입점
void main() async {
  // EN: Ensure Flutter binding is initialized
  // KO: Flutter 바인딩 초기화 확인
  WidgetsFlutterBinding.ensureInitialized();

  // EN: Initialize shared preferences
  // KO: 공유 환경설정 초기화
  final sharedPreferences = await SharedPreferences.getInstance();

  // EN: Create Dio instance for HTTP client
  // KO: HTTP 클라이언트용 Dio 인스턴스 생성
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // EN: Add request/response logging for development
  // KO: 개발용 요청/응답 로깅 추가
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      logPrint: (object) => debugPrint(object.toString()),
    ));
  }

  // EN: Create network client
  // KO: 네트워크 클라이언트 생성
  final networkClient = DioNetworkClient(
    dio: dio,
    defaultDecoder: (data) {
      // EN: Default JSON decoder for API responses
      // KO: API 응답용 기본 JSON 디코더
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'data': data};
    },
  );

  // EN: Run app with provider overrides for dependency injection
  // KO: 의존성 주입을 위한 프로바이더 오버라이드와 함께 앱 실행
  runApp(
    ProviderScope(
      overrides: [
        // EN: Override providers with concrete implementations
        // KO: 구체적 구현체로 프로바이더 오버라이드
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        networkClientProvider.overrideWithValue(networkClient),
      ],
      child: const App(),
    ),
  );
}

/// EN: Development environment configuration
/// KO: 개발 환경 구성
class DevConfig {
  static const String apiBaseUrl = 'https://api.girlsbandtabi.dev';
  static const bool enableLogging = true;
  static const Duration networkTimeout = Duration(seconds: 30);
}

/// EN: Production environment configuration
/// KO: 프로덕션 환경 구성
class ProdConfig {
  static const String apiBaseUrl = 'https://api.girlsbandtabi.com';
  static const bool enableLogging = false;
  static const Duration networkTimeout = Duration(seconds: 15);
}