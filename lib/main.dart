/// EN: Application entry point
/// KO: 앱 진입점
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'core/providers/core_providers.dart';

Future<void> main() async {
  // EN: Ensure Flutter bindings are initialized
  // KO: Flutter 바인딩 초기화 확인
  WidgetsFlutterBinding.ensureInitialized();

  // EN: Initialize app configuration
  // KO: 앱 구성 초기화
  final environment =
      kReleaseMode ? Environment.production : Environment.development;
  AppConfig.instance.init(
    environment: environment,
    // EN: Override with actual values for production.
    // KO: 프로덕션에서는 실제 값으로 오버라이드.
  );

  AppLogger.info('App starting', tag: 'Main');
  AppLogger.info('Environment: ${AppConfig.instance.environment.name}');
  AppLogger.info('Base URL: ${AppConfig.instance.baseUrl}');

  // EN: Set preferred orientations
  // KO: 선호 방향 설정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // EN: Set system UI overlay style
  // KO: 시스템 UI 오버레이 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // EN: Create provider container for pre-initialization
  // KO: 사전 초기화를 위한 프로바이더 컨테이너 생성
  final container = ProviderContainer();

  // EN: Pre-initialize local storage
  // KO: 로컬 저장소 사전 초기화
  await container.read(localStorageProvider.future);

  // EN: Check authentication status
  // KO: 인증 상태 확인
  await container.read(authStateProvider.notifier).checkAuthStatus();

  AppLogger.info('App initialization complete', tag: 'Main');

  // EN: Run the app with Riverpod
  // KO: Riverpod과 함께 앱 실행
  runApp(
    UncontrolledProviderScope(container: container, child: const GBTApp()),
  );
}
