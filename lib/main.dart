/// EN: Application entry point
/// KO: 앱 진입점
library;

import 'dart:async';

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

  // EN: Enable edge-to-edge mode — app renders behind system bars on Android.
  //     iOS handles this natively via SafeArea / home indicator insets.
  // KO: 엣지 투 엣지 모드 활성화 — Android에서 앱이 시스템 바 뒤까지 렌더링됩니다.
  //     iOS는 SafeArea / 홈 인디케이터 인셋으로 자동 처리됩니다.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // EN: Initial overlay style — transparent bars, icon brightness set at runtime
  //     via AnnotatedRegion in app.dart based on the active theme.
  // KO: 초기 오버레이 스타일 — 투명 바, 아이콘 밝기는 app.dart의 AnnotatedRegion에서
  //     활성 테마에 따라 런타임에 설정됩니다.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // EN: Create provider container for pre-initialization
  // KO: 사전 초기화를 위한 프로바이더 컨테이너 생성
  final container = ProviderContainer();

  // EN: Run the app with Riverpod
  // KO: Riverpod과 함께 앱 실행
  runApp(
    UncontrolledProviderScope(container: container, child: const GBTApp()),
  );

  // EN: Bootstrap critical services without blocking the first frame.
  // KO: 첫 프레임을 막지 않도록 핵심 서비스를 부트스트랩합니다.
  unawaited(_bootstrap(container));
}

/// EN: Non-blocking bootstrap for storage + auth checks.
/// KO: 스토리지 + 인증 확인을 위한 논블로킹 부트스트랩.
Future<void> _bootstrap(ProviderContainer container) async {
  try {
    // EN: Pre-initialize local storage.
    // KO: 로컬 저장소 사전 초기화.
    await container.read(localStorageProvider.future);

    // EN: Check authentication status.
    // KO: 인증 상태 확인.
    await container.read(authStateProvider.notifier).checkAuthStatus();

    AppLogger.info('App initialization complete', tag: 'Main');
  } catch (error, stackTrace) {
    AppLogger.error(
      'App bootstrap failed',
      error: error,
      stackTrace: stackTrace,
      tag: 'Main',
    );
  }
}
