/// EN: GBT bottom navigation bar — Spotify/Instagram style simple nav.
/// KO: Spotify/Instagram 스타일의 심플한 GBT 하단 네비게이션 바.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

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

/// EN: Bottom navigation bar widget with simple color-change selection.
/// KO: 간단한 색상 변경 선택을 사용하는 하단 네비게이션 바 위젯.
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

  /// EN: Navigation bar height.
  /// KO: 네비게이션 바 높이.
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        // EN: Top border line for subtle separation
        // KO: 미세한 분리를 위한 상단 테두리 라인
        border: Border(
          top: BorderSide(
            color: isDark
                ? GBTColors.darkBorderSubtle
                : GBTColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
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
                tabIndex: index,
                totalTabs: items.length,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// EN: Individual bottom nav item — stateless, color-change only.
/// KO: 개별 하단 네비 아이템 — 상태 없음, 색상 변경만.
class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    required this.tabIndex,
    required this.totalTabs,
  });

  final GBTBottomNavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final int tabIndex;
  final int totalTabs;

  @override
  Widget build(BuildContext context) {
    // EN: Use darkPrimary (lighter purple) for selected state in dark mode
    // KO: 다크 모드에서 선택 상태에 darkPrimary (밝은 보라) 사용
    final selectedColor = isDark
        ? GBTColors.darkPrimary
        : GBTColors.primary;
    final unselectedColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final color = isSelected ? selectedColor : unselectedColor;

    return Expanded(
      child: Semantics(
        label: item.semanticLabel ?? item.label,
        hint: isSelected
            ? null
            : '탭하면 ${item.label} 탭으로 이동합니다',
        button: true,
        selected: isSelected,
        // EN: Provide tab position info for screen readers
        // KO: 스크린 리더를 위한 탭 위치 정보 제공
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // EN: Fixed 24px icon, active/inactive swap
              // KO: 고정 24px 아이콘, 활성/비활성 전환
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: color,
                size: GBTSpacing.iconMd, // 24px
              ),
              const SizedBox(height: GBTSpacing.xxs),
              // EN: Fixed 11px label, w500 selected / w400 unselected
              // KO: 고정 11px 라벨, 선택 시 w500 / 미선택 시 w400
              Text(
                item.label,
                style: GBTTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: isSelected
                      ? FontWeight.w500
                      : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
