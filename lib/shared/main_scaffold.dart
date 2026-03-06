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
    final isBoardBranch = currentIndex == 3;
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
        bottomNavigationBar: isBoardBranch
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
                  ref.read(currentNavIndexProvider.notifier).state = 3;
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
                    icon: Icons.forum_outlined,
                    activeIcon: Icons.forum,
                    label: context.l10n(ko: '게시판', en: 'Board', ja: '掲示板'),
                  ),
                  GBTBottomNavItem(
                    icon: Icons.auto_stories_outlined,
                    activeIcon: Icons.auto_stories,
                    label: context.l10n(ko: '정보', en: 'Info', ja: '情報'),
                  ),
                ],
                currentIndex: currentIndex,
                onTap: (index) => _onTap(context, index),
              ),
      ),
    );
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
    if (index == 3 && widget.navigationShell.currentIndex != 3) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.38);

    const radius = Radius.circular(40);
    const borderRadius = BorderRadius.vertical(top: radius);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
            blurRadius: 36,
            offset: const Offset(0, -8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0A0A0A).withValues(alpha: 0.60)
                  : Colors.white.withValues(alpha: 0.76),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.09)
                      : Colors.white.withValues(alpha: 0.60),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: GBTSpacing.bottomNavHeight,
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: context.l10n(
                        ko: '이전 화면으로 돌아가기',
                        en: 'Go back to previous screen',
                        ja: '前の画面に戻る',
                      ),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onBackTap();
                        },
                        child: const SizedBox(
                          width: 54,
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: _BoardSubSection.values.map((value) {
                          final isSelected = value == section;
                          final iconColor = isSelected
                              ? primaryColor
                              : inactiveColor;
                          final labelColor = isSelected
                              ? primaryColor
                              : inactiveColor;
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
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onSectionChanged(value);
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
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
                                          color: iconColor,
                                          size: isSelected ? 24 : 22,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        value.label(context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: labelColor,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
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
      ),
    );
  }
}
