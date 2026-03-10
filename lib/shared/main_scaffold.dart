/// EN: Main scaffold with 5-tab navigation and board-specific sub bottom bar.
/// KO: 5탭 네비게이션과 게시판 전용 서브 하단바를 포함한 메인 스캐폴드.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/locale_text.dart';
import '../core/providers/core_providers.dart';
import '../core/theme/gbt_colors.dart';
import '../core/theme/gbt_spacing.dart';
import '../core/widgets/navigation/gbt_bottom_nav.dart';

/// EN: Main scaffold widget with stateful navigation shell
/// KO: 상태 유지 네비게이션 쉘을 포함한 메인 스캐폴드 위젯
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  static const Duration _androidExitBackWindow = Duration(seconds: 3);

  int? _lastSyncedIndex;
  bool _syncScheduled = false;
  DateTime? _lastBackPressed;
  String _lastNonBoardLocation = '/home';

  void _scheduleSync(int index) {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted || _lastSyncedIndex == index) return;
      _lastSyncedIndex = index;
      ref.read(currentNavIndexProvider.notifier).state = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final canNavigateBack = GoRouter.of(context).canPop();
    final currentUri = GoRouterState.of(context).uri;
    final currentPath = currentUri.path;
    final currentLocation = currentUri.toString();
    final isBoardBranch = currentIndex == 4;
    final isBoardRoot = isBoardBranch && _isBoardRootRoute(currentPath);
    final shouldShowBottomNav = _shouldShowBottomNav(
      currentIndex: currentIndex,
      currentPath: currentPath,
    );
    if (!isBoardBranch) {
      _lastNonBoardLocation = currentLocation;
    }
    if (_lastSyncedIndex != currentIndex) {
      _scheduleSync(currentIndex);
    }

    return PopScope(
      canPop: canNavigateBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || canNavigateBack) return;
        if (defaultTargetPlatform == TargetPlatform.android && isBoardRoot) {
          final target = _lastNonBoardLocation;
          context.go(
            target.startsWith('/board') || target.isEmpty ? '/home' : target,
          );
          return;
        }
        if (defaultTargetPlatform != TargetPlatform.android) {
          return;
        }
        final now = DateTime.now();
        if (_lastBackPressed != null &&
            now.difference(_lastBackPressed!) < _androidExitBackWindow) {
          SystemNavigator.pop();
          return;
        }
        _lastBackPressed = now;
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              context.l10n(
                ko: '뒤로 버튼을 한 번 더 누르면 앱이 종료됩니다',
                en: 'Press back again within 3 seconds to exit',
                ja: '3秒以内にもう一度戻るを押すと終了します',
              ),
            ),
            duration: _androidExitBackWindow,
          ),
        );
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: !shouldShowBottomNav
            ? null
            : isBoardBranch
            ? _BoardSubBottomNav(
                section: _resolveBoardSection(currentPath),
                onBackTap: () {
                  final target = _lastNonBoardLocation;
                  context.go(
                    target.startsWith('/board') || target.isEmpty
                        ? '/home'
                        : target,
                  );
                },
                onSectionChanged: (section) {
                  ref.read(currentNavIndexProvider.notifier).state = 4;
                  switch (section) {
                    case _BoardSubSection.feed:
                      context.go('/board');
                    case _BoardSubSection.discover:
                      context.go('/board/discover');
                    case _BoardSubSection.travelReview:
                      context.go('/board/travel-reviews-tab');
                  }
                },
              )
            : GBTBottomNav(
                items: [
                  GBTBottomNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: context.l10n(ko: '홈', en: 'Home', ja: 'ホーム'),
                  ),
                  GBTBottomNavItem(
                    icon: Icons.place_outlined,
                    activeIcon: Icons.place,
                    label: context.l10n(ko: '장소', en: 'Places', ja: '場所'),
                  ),
                  GBTBottomNavItem(
                    icon: Icons.music_note_outlined,
                    activeIcon: Icons.music_note,
                    label: context.l10n(ko: '라이브', en: 'Live', ja: 'ライブ'),
                  ),
                  GBTBottomNavItem(
                    icon: Icons.auto_stories_outlined,
                    activeIcon: Icons.auto_stories,
                    label: context.l10n(ko: '정보', en: 'Info', ja: '情報'),
                  ),
                  GBTBottomNavItem(
                    icon: Icons.forum_outlined,
                    activeIcon: Icons.forum,
                    label: context.l10n(ko: '게시판', en: 'Board', ja: '掲示板'),
                  ),
                ],
                currentIndex: currentIndex,
                onTap: (index) => _onTap(context, index),
              ),
      ),
    );
  }

  bool _shouldShowBottomNav({
    required int currentIndex,
    required String currentPath,
  }) {
    if (currentIndex == 4) {
      return _isBoardRootRoute(currentPath);
    }
    if (currentIndex == 0) {
      return currentPath == '/home';
    }
    if (currentIndex == 1) {
      return currentPath == '/places';
    }
    if (currentIndex == 2) {
      return currentPath == '/live';
    }
    if (currentIndex == 3) {
      return currentPath == '/info';
    }
    return false;
  }

  bool _isBoardRootRoute(String path) {
    return path == '/board' ||
        path == '/board/discover' ||
        path == '/board/travel-reviews-tab';
  }

  _BoardSubSection _resolveBoardSection(String path) {
    if (path.startsWith('/board/travel-reviews-tab')) {
      return _BoardSubSection.travelReview;
    }
    if (path.startsWith('/board/discover')) {
      return _BoardSubSection.discover;
    }
    return _BoardSubSection.feed;
  }

  /// EN: Handle bottom navigation tap
  /// KO: 하단 네비게이션 탭 처리
  void _onTap(BuildContext context, int index) {
    if (index == 4 && widget.navigationShell.currentIndex != 4) {
      _lastNonBoardLocation = GoRouterState.of(context).uri.toString();
    }
    widget.navigationShell.goBranch(
      index,
      // EN: Navigate to initial location if tapping current tab
      // KO: 현재 탭을 탭하면 초기 위치로 이동
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    _lastSyncedIndex = index;
    ref.read(currentNavIndexProvider.notifier).state = index;
  }
}

enum _BoardSubSection { feed, discover, travelReview }

extension on _BoardSubSection {
  String label(BuildContext context) => switch (this) {
    _BoardSubSection.feed => context.l10n(ko: '피드', en: 'Feed', ja: 'フィード'),
    _BoardSubSection.discover => context.l10n(
      ko: '발견',
      en: 'Discover',
      ja: '発見',
    ),
    _BoardSubSection.travelReview => context.l10n(
      ko: '여행후기',
      en: 'Travel Reviews',
      ja: '旅行レビュー',
    ),
  };

  IconData get icon => switch (this) {
    _BoardSubSection.feed => Icons.dynamic_feed_outlined,
    _BoardSubSection.discover => Icons.explore_outlined,
    _BoardSubSection.travelReview => Icons.rate_review_outlined,
  };
}

class _BoardSubBottomNav extends StatelessWidget {
  const _BoardSubBottomNav({
    required this.section,
    required this.onBackTap,
    required this.onSectionChanged,
  });

  final _BoardSubSection section;
  final VoidCallback onBackTap;
  final ValueChanged<_BoardSubSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.android) {
      return _buildAndroidBoardSubBottomNav(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final navCornerRadius = isIos ? 38.0 : 34.0;
    final navShape = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(navCornerRadius),
    );
    final selectedColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final unselectedColor = isDark
        ? GBTColors.darkTextSecondary.withValues(alpha: 0.82)
        : GBTColors.textSecondary.withValues(alpha: 0.82);
    final gradientColors = isDark
        ? [
            GBTColors.darkSurface.withValues(alpha: 0.95),
            GBTColors.darkSurfaceVariant.withValues(alpha: 0.95),
          ]
        : [
            GBTColors.surface.withValues(alpha: 0.95),
            GBTColors.appBackground.withValues(alpha: 0.95),
          ];
    final borderColor = isDark
        ? GBTColors.darkBorder.withValues(alpha: 0.72)
        : GBTColors.border.withValues(alpha: 0.82);
    final backButtonColor = isDark
        ? GBTColors.darkSurfaceElevated.withValues(alpha: 0.78)
        : GBTColors.surfaceVariant.withValues(alpha: 0.90);
    final backIconColor = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        height: GBTSpacing.bottomNavHeight + 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(navCornerRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.16),
              blurRadius: isDark ? 30 : 24,
              offset: const Offset(0, 10),
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipPath(
          // EN: iOS-like continuous corner profile for the board sub-nav pill.
          // KO: 게시판 서브 내비게이션 pill에 iOS 스타일의 연속 곡률을 적용합니다.
          clipper: ShapeBorderClipper(shape: navShape),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
                border: Border.all(color: borderColor, width: 0.8),
                borderRadius: BorderRadius.circular(navCornerRadius),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Semantics(
                      button: true,
                      label: context.l10n(
                        ko: '이전 화면으로 돌아가기',
                        en: 'Go back to previous screen',
                        ja: '前の画面に戻る',
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkResponse(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onBackTap();
                          },
                          radius: 28,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: backButtonColor,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 30,
                              color: backIconColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: _BoardSubSection.values.map((value) {
                        final isSelected = value == section;
                        final itemColor = isSelected
                            ? selectedColor
                            : unselectedColor;
                        return Expanded(
                          child: Semantics(
                            button: true,
                            selected: isSelected,
                            label:
                                '${value.label(context)} ${context.l10n(ko: '탭', en: 'tab', ja: 'タブ')}',
                            hint: isSelected
                                ? context.l10n(
                                    ko: '현재 선택됨',
                                    en: 'Currently selected',
                                    ja: '現在選択中',
                                  )
                                : context.l10n(
                                    ko: '탭하면 이동합니다',
                                    en: 'Tap to switch',
                                    ja: 'タップして切り替え',
                                  ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onSectionChanged(value);
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 6,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        child: Icon(
                                          value.icon,
                                          key: ValueKey(
                                            '${value.name}-$isSelected',
                                          ),
                                          color: itemColor,
                                          size: isSelected ? 24 : 22,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        value.label(context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: itemColor,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              fontSize: 10.5,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidBoardSubBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: colorScheme.surface,
        child: SizedBox(
          height: GBTSpacing.bottomNavHeight,
          child: Row(
            children: [
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onBackTap();
                },
                tooltip: context.l10n(
                  ko: '이전 화면으로 돌아가기',
                  en: 'Go back to previous screen',
                  ja: '前の画面に戻る',
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Row(
                  children: _BoardSubSection.values
                      .map((value) {
                        final isSelected = value == section;
                        final itemColor = isSelected
                            ? selectedColor
                            : unselectedColor;
                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onSectionChanged(value);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    value.icon,
                                    color: itemColor,
                                    size: isSelected ? 24 : 22,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    value.label(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: itemColor,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
