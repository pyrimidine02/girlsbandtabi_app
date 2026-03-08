/// EN: Main application widget with theme and router configuration
/// KO: 테마 및 라우터 구성을 포함한 메인 앱 위젯
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/constants/legal_policy_constants.dart';
import 'core/connectivity/connectivity_service.dart';
import 'core/localization/locale_text.dart';
import 'core/notifications/local_notifications_service.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/gbt_colors.dart';
import 'core/theme/gbt_spacing.dart';
import 'core/theme/gbt_typography.dart';
import 'core/theme/gbt_theme.dart';
import 'features/notifications/application/notifications_controller.dart';
import 'features/notifications/domain/entities/notification_navigation.dart';
import 'features/settings/application/mandatory_consent_controller.dart';

/// EN: Main application widget
/// KO: 메인 앱 위젯
class GBTApp extends ConsumerWidget {
  const GBTApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // EN: Keep notification realtime sync alive at app scope.
    // KO: 앱 전역에서 알림 실시간 동기화를 유지합니다.
    ref.watch(notificationsRealtimeBootstrapProvider);
    // EN: Keep remote push registration/tap handling alive at app scope.
    // KO: 앱 전역에서 원격 푸시 등록/탭 처리를 유지합니다.
    ref.watch(remotePushBootstrapProvider);

    final router = ref.watch(appRouterProvider);
    ref.listen<AsyncValue<LocalNotificationTapEvent>>(
      localNotificationTapEventsProvider,
      (_, next) {
        next.whenData(
          (tapEvent) => _handleLocalNotificationTap(
            ref: ref,
            router: router,
            tapEvent: tapEvent,
          ),
        );
      },
    );
    ref.listen<AsyncValue<LocalNotificationTapEvent>>(
      remotePushTapEventsProvider,
      (_, next) {
        next.whenData(
          (tapEvent) => _handleLocalNotificationTap(
            ref: ref,
            router: router,
            tapEvent: tapEvent,
          ),
        );
      },
    );
    unawaited(ref.read(localNotificationsServiceProvider).initialize());

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
                child: _MandatoryConsentGate(
                  child: _NotificationsLifecycleBridge(
                    child: _ConnectivityWrapper(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
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

  void _handleLocalNotificationTap({
    required WidgetRef ref,
    required GoRouter router,
    required LocalNotificationTapEvent tapEvent,
  }) {
    final notifier = ref.read(notificationsControllerProvider.notifier);
    if (tapEvent.notificationId.isNotEmpty) {
      unawaited(notifier.markAsRead(tapEvent.notificationId, refresh: false));
    }

    final targetPath =
        resolveNotificationNavigationPath(
          type: tapEvent.type,
          deeplink: tapEvent.deeplink,
          actionUrl: tapEvent.actionUrl,
          entityId: tapEvent.entityId,
        ) ??
        '/notifications';

    final currentPath = router.routeInformationProvider.value.uri.path;
    if (currentPath != targetPath) {
      router.go(targetPath);
    }
    unawaited(notifier.refreshInBackground(minInterval: Duration.zero));
  }
}

/// EN: Mandatory consent gate overlay for authenticated users.
/// KO: 인증 사용자 대상 필수 동의 게이트 오버레이입니다.
class _MandatoryConsentGate extends ConsumerWidget {
  const _MandatoryConsentGate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final state = ref.watch(mandatoryConsentControllerProvider);

    final shouldBlockForLoading =
        isAuthenticated && state.isLoading && !state.isRequired;
    final shouldShowConsentOverlay = isAuthenticated && state.isRequired;

    if (!shouldBlockForLoading && !shouldShowConsentOverlay) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ColoredBox(
            color: shouldShowConsentOverlay
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.1),
            child: shouldShowConsentOverlay
                ? SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(GBTSpacing.md),
                        child: _MandatoryConsentOverlay(
                          missingTypes: state.missingTypes,
                        ),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _MandatoryConsentOverlay extends ConsumerStatefulWidget {
  const _MandatoryConsentOverlay({required this.missingTypes});

  final Set<RequiredConsentType> missingTypes;

  @override
  ConsumerState<_MandatoryConsentOverlay> createState() =>
      _MandatoryConsentOverlayState();
}

class _MandatoryConsentOverlayState
    extends ConsumerState<_MandatoryConsentOverlay> {
  late bool _agreeTerms;
  late bool _agreePrivacy;

  @override
  void initState() {
    super.initState();
    _agreeTerms = !widget.missingTypes.contains(
      RequiredConsentType.termsOfService,
    );
    _agreePrivacy = !widget.missingTypes.contains(
      RequiredConsentType.privacyPolicy,
    );
  }

  @override
  void didUpdateWidget(covariant _MandatoryConsentOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.missingTypes != widget.missingTypes) {
      _agreeTerms = !widget.missingTypes.contains(
        RequiredConsentType.termsOfService,
      );
      _agreePrivacy = !widget.missingTypes.contains(
        RequiredConsentType.privacyPolicy,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mandatoryConsentControllerProvider);
    final canSubmit = _agreeTerms && _agreePrivacy && !state.isSubmitting;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final terms = LegalPolicyConstants.byType(LegalPolicyType.termsOfService);
    final privacy = LegalPolicyConstants.byType(LegalPolicyType.privacyPolicy);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Material(
        color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface,
        elevation: 10,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(GBTSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n(
                  ko: '서비스 이용을 위해 동의가 필요해요',
                  en: 'Consent is required to continue',
                  ja: 'サービス利用には同意が必要です',
                ),
                style: GBTTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                context.l10n(
                  ko: '이용약관과 개인정보 처리방침 동의 전에는 앱을 사용할 수 없습니다.',
                  en: 'You cannot use the app until required consents are accepted.',
                  ja: '必須同意前はアプリを利用できません。',
                ),
                style: GBTTypography.bodySmall,
              ),
              const SizedBox(height: GBTSpacing.md),
              _MandatoryConsentCheckTile(
                title: context.l10n(
                  ko: '이용약관 동의 (필수)',
                  en: 'Terms of service (required)',
                  ja: '利用規約への同意（必須）',
                ),
                version: terms.version,
                checked: _agreeTerms,
                onChanged: (value) {
                  setState(() => _agreeTerms = value ?? false);
                },
                onOpenPolicy: () => _openPolicy(context, terms.url),
              ),
              const SizedBox(height: GBTSpacing.xs),
              _MandatoryConsentCheckTile(
                title: context.l10n(
                  ko: '개인정보 처리방침 동의 (필수)',
                  en: 'Privacy policy (required)',
                  ja: 'プライバシーポリシーへの同意（必須）',
                ),
                version: privacy.version,
                checked: _agreePrivacy,
                onChanged: (value) {
                  setState(() => _agreePrivacy = value ?? false);
                },
                onOpenPolicy: () => _openPolicy(context, privacy.url),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: GBTSpacing.sm),
                Text(
                  state.errorMessage!,
                  style: GBTTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: GBTSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canSubmit ? _submit : null,
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          context.l10n(
                            ko: '동의하고 계속',
                            en: 'Agree and continue',
                            ja: '同意して続行',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await ref
        .read(mandatoryConsentControllerProvider.notifier)
        .submitRequiredConsents(
          agreeTermsOfService: _agreeTerms,
          agreePrivacyPolicy: _agreePrivacy,
        );
  }

  Future<void> _openPolicy(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n(
            ko: '정책 문서를 열 수 없습니다.',
            en: 'Unable to open policy document.',
            ja: 'ポリシー文書を開けません。',
          ),
        ),
      ),
    );
  }
}

class _MandatoryConsentCheckTile extends StatelessWidget {
  const _MandatoryConsentCheckTile({
    required this.title,
    required this.version,
    required this.checked,
    required this.onChanged,
    required this.onOpenPolicy,
  });

  final String title;
  final String version;
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onOpenPolicy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Checkbox(value: checked, onChanged: onChanged),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GBTTypography.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    version,
                    style: GBTTypography.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: onOpenPolicy,
            child: Text(context.l10n(ko: '보기', en: 'View', ja: '表示')),
          ),
        ],
      ),
    );
  }
}

/// EN: Lifecycle bridge to enforce SSE single-connection policy per app session.
/// KO: 앱 세션 단일 SSE 연결 정책을 강제하는 라이프사이클 브리지입니다.
class _NotificationsLifecycleBridge extends ConsumerStatefulWidget {
  const _NotificationsLifecycleBridge({required this.child});

  final Widget child;

  @override
  ConsumerState<_NotificationsLifecycleBridge> createState() =>
      _NotificationsLifecycleBridgeState();
}

class _NotificationsLifecycleBridgeState
    extends ConsumerState<_NotificationsLifecycleBridge>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!ref.read(isAuthenticatedProvider)) {
      return;
    }
    final notifier = ref.read(notificationsControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(notifier.startRealtimeSync());
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(notifier.stopRealtimeSync());
        break;
      case AppLifecycleState.inactive:
        // EN: Ignore transient inactive transitions.
        // KO: 일시적 inactive 전환은 무시합니다.
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
