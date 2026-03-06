/// EN: Main application widget with theme and router configuration
/// KO: 테마 및 라우터 구성을 포함한 메인 앱 위젯
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'core/connectivity/connectivity_service.dart';
import 'core/localization/locale_text.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/gbt_colors.dart';
import 'core/theme/gbt_theme.dart';
import 'features/notifications/application/notifications_controller.dart';

/// EN: Main application widget
/// KO: 메인 앱 위젯
class GBTApp extends ConsumerWidget {
  const GBTApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // EN: Keep notification realtime sync alive at app scope.
    // KO: 앱 전역에서 알림 실시간 동기화를 유지합니다.
    ref.watch(notificationsRealtimeBootstrapProvider);

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appLocale = ref.watch(localeProvider);

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
      locale: appLocale,
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundGradient = isDark
            ? GBTColors.darkAppBackgroundGradient
            : GBTColors.appBackgroundGradient;
        Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();
        // EN: Icon brightness flips with theme so status bar & nav bar icons
        //     remain readable in both light and dark mode (edge-to-edge).
        // KO: 테마에 따라 아이콘 밝기를 반전시켜 라이트/다크 모드 모두에서
        //     상태 바·네비게이션 바 아이콘이 잘 보이도록 합니다 (엣지 투 엣지).
        final iconBrightness = isDark ? Brightness.light : Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: iconBrightness,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: iconBrightness,
            systemNavigationBarContrastEnforced: false,
          ),
          child: MediaQuery(
            // EN: Prevent text scaling beyond 1.3x for accessibility
            // KO: 접근성을 위해 텍스트 스케일링을 1.3배 이하로 제한
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: backgroundGradient),
                child: _ConnectivityWrapper(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
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
class _ConnectivityWrapper extends ConsumerStatefulWidget {
  const _ConnectivityWrapper({required this.child});

  final Widget child;

  @override
  ConsumerState<_ConnectivityWrapper> createState() =>
      _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends ConsumerState<_ConnectivityWrapper> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _isOffline = _resolveOffline(ref.read(connectivityStatusProvider));
  }

  bool _resolveOffline(AsyncValue<ConnectivityStatus> value) {
    return value.valueOrNull == ConnectivityStatus.offline;
  }

  void _scheduleOfflineUpdate(bool isOffline) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isOffline == isOffline) return;
      setState(() => _isOffline = isOffline);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOfflineNow = _resolveOffline(ref.watch(connectivityStatusProvider));
    if (isOfflineNow != _isOffline) {
      _scheduleOfflineUpdate(isOfflineNow);
    }

    // EN: Keep Positioned wrapper stable to avoid parentData dirty during
    // semantics flush — only swap the content inside.
    // KO: semantics flush 중 parentData dirty를 방지하기 위해 Positioned 래퍼를
    // 안정적으로 유지 — 내부 콘텐츠만 교체.
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _isOffline
              ? IgnorePointer(child: _OfflineBanner())
              : const SizedBox.shrink(),
        ),
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
                context.l10n(
                  ko: '오프라인 모드 - 일부 기능이 제한됩니다',
                  en: 'Offline mode - some features are limited',
                  ja: 'オフラインモード - 一部機能は制限されます',
                ),
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
