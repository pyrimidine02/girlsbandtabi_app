/// EN: Main application widget with theme and router configuration
/// KO: 테마 및 라우터 구성을 포함한 메인 앱 위젯
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/connectivity/connectivity_service.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/gbt_theme.dart';

/// EN: Main application widget
/// KO: 메인 앱 위젯
class GBTApp extends ConsumerWidget {
  const GBTApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Girls Band Tabi',
      debugShowCheckedModeBanner: false,

      // EN: Theme configuration
      // KO: 테마 구성
      theme: GBTTheme.light,
      darkTheme: GBTTheme.dark,
      themeMode: _parseThemeMode(themeMode),

      // EN: Router configuration
      // KO: 라우터 구성
      routerConfig: router,

      // EN: Localization
      // KO: 다국어 지원
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
        Locale('ja', 'JP'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // EN: Builder for global overlays
      // KO: 전역 오버레이를 위한 빌더
      builder: (context, child) {
        return MediaQuery(
          // EN: Prevent text scaling beyond 1.3x for accessibility
          // KO: 접근성을 위해 텍스트 스케일링을 1.3배 이하로 제한
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: _ConnectivityWrapper(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }

  /// EN: Parse theme mode string to ThemeMode enum
  /// KO: 테마 모드 문자열을 ThemeMode 열거형으로 파싱
  ThemeMode _parseThemeMode(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

/// EN: Wrapper widget for connectivity status display
/// KO: 연결 상태 표시를 위한 래퍼 위젯
class _ConnectivityWrapper extends ConsumerWidget {
  const _ConnectivityWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return Column(
      children: [
        // EN: Offline banner
        // KO: 오프라인 배너
        connectivityAsync.when(
          data: (status) {
            if (status == ConnectivityStatus.offline) {
              return _OfflineBanner();
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // EN: Main content
        // KO: 메인 콘텐츠
        Expanded(child: child),
      ],
    );
  }
}

/// EN: Offline status banner widget
/// KO: 오프라인 상태 배너 위젯
class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).colorScheme.error,
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 16,
                color: Theme.of(context).colorScheme.onError,
              ),
              const SizedBox(width: 8),
              Text(
                '오프라인 모드 - 일부 기능이 제한됩니다',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
