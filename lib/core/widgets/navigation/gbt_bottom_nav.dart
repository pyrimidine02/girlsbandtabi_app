/// EN: GBT bottom navigation bar — liquid glass Baemin-style bar with
///     backdrop blur, rounded top corners matching iPhone screen corner radius.
/// KO: GBT 하단 네비게이션 바 — 백드롭 블러를 이용한 리퀴드 글라스 배민 스타일 바.
///     아이폰 화면 곡률에 맞는 상단 둥근 모서리.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';
import '../../theme/gbt_animations.dart';

/// EN: Bottom navigation item definition.
/// KO: 하단 네비게이션 아이템 정의.
class GBTBottomNavItem {
  const GBTBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.semanticLabel,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? semanticLabel;
}

/// EN: Bottom navigation bar — liquid glass Baemin style.
///     Full-width, rounded top corners (radius 40 dp ≈ iPhone screen corner),
///     backdrop blur frosted glass surface, vertical icon-above-label layout.
/// KO: 하단 네비게이션 바 — 리퀴드 글라스 배민 스타일.
///     전체 폭, 아이폰 화면 곡률에 맞는 상단 둥근 모서리 (반경 40 dp),
///     백드롭 블러 반투명 유리 표면, 아이콘-위-라벨 수직 레이아웃.
class GBTBottomNav extends StatelessWidget {
  const GBTBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = GBTSpacing.bottomNavHeight,
  });

  /// EN: Navigation items.
  /// KO: 네비게이션 아이템 목록.
  final List<GBTBottomNavItem> items;

  /// EN: Currently selected index.
  /// KO: 현재 선택된 인덱스.
  final int currentIndex;

  /// EN: Tap handler for item selection.
  /// KO: 아이템 선택 시 탭 핸들러.
  final ValueChanged<int> onTap;

  /// EN: Navigation bar content height (excluding safe area).
  /// KO: 네비게이션 바 콘텐츠 높이 (SafeArea 제외).
  final double height;

  static const _kRadius = Radius.circular(40);
  static const _kBorderRadius = BorderRadius.vertical(top: _kRadius);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.android) {
      return _buildAndroidBottomNav(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // EN: Outer shadow — rendered outside ClipRRect so it's not clipped.
      // KO: 외부 그림자 — ClipRRect에 의해 잘리지 않도록 외부에 배치.
      decoration: BoxDecoration(
        borderRadius: _kBorderRadius,
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
        borderRadius: _kBorderRadius,
        child: BackdropFilter(
          // EN: Blur what's behind the bar — liquid glass core effect.
          // KO: 바 뒤쪽 화면을 블러 처리 — 리퀴드 글라스 핵심 효과.
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              // EN: Semi-transparent fill over the blur.
              // KO: 블러 위에 반투명 채색.
              color: isDark
                  ? const Color(0xFF0A0A0A).withValues(alpha: 0.60)
                  : Colors.white.withValues(alpha: 0.76),
              // EN: Top glass edge — subtle highlight line.
              // KO: 상단 유리 테두리 — 미세한 하이라이트 선.
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
                height: height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    items.length,
                    (index) => _BottomNavItem(
                      item: items[index],
                      isSelected: currentIndex == index,
                      isDark: isDark,
                      onTap: () => onTap(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidBottomNav(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: NavigationBar(
        selectedIndex: currentIndex,
        height: height,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          onTap(index);
        },
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
                tooltip: item.semanticLabel ?? item.label,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

/// EN: Individual bottom nav item — vertical icon + label layout (Baemin style).
/// KO: 개별 하단 네비 아이템 — 수직 아이콘 + 라벨 레이아웃 (배민 스타일).
class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final GBTBottomNavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    // EN: On glass bg unselected items use a slightly stronger neutral for legibility.
    // KO: 유리 배경에서 미선택 아이템은 가독성을 위해 약간 더 강한 중립색 사용.
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.38);
    final iconColor = isSelected ? selectedColor : unselectedColor;
    final labelColor = isSelected ? selectedColor : unselectedColor;

    return Expanded(
      child: Semantics(
        label: item.semanticLabel ?? item.label,
        hint: isSelected ? null : '탭하면 ${item.label} 탭으로 이동합니다',
        button: true,
        selected: isSelected,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: GBTAnimations.fast,
            curve: GBTAnimations.defaultCurve,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: GBTAnimations.fast,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey(isSelected),
                    color: iconColor,
                    // EN: Slightly larger icon when selected for visual emphasis.
                    // KO: 선택 시 아이콘 약간 크게 — 시각적 강조.
                    size: isSelected ? 24 : 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GBTTypography.labelSmall.copyWith(
                    color: labelColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
