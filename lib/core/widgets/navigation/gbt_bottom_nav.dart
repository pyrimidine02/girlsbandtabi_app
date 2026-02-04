/// EN: GBT bottom navigation bar for 5-tab structure.
/// KO: 5탭 구조를 위한 GBT 하단 네비게이션 바.
library;

import 'package:flutter/material.dart';

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

/// EN: Bottom navigation bar widget.
/// KO: 하단 네비게이션 바 위젯.
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final GBTBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? GBTColors.primary : GBTColors.textTertiary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Semantics(
            label: item.semanticLabel ?? item.label,
            button: true,
            selected: isSelected,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: color,
                  size: GBTSpacing.iconMd,
                ),
                const SizedBox(height: GBTSpacing.xxs),
                Text(
                  item.label,
                  style: GBTTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
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
