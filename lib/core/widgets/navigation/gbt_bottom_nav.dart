/// EN: GBT bottom navigation bar for 5-tab structure with animations.
/// KO: 애니메이션을 포함한 5탭 구조를 위한 GBT 하단 네비게이션 바.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_decorations.dart';
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

/// EN: Bottom navigation bar widget with animated selection indicator.
/// KO: 애니메이션 선택 인디케이터를 포함한 하단 네비게이션 바 위젯.
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
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
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GBTAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.primary;
    final unselectedColor = widget.isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final color = widget.isSelected ? selectedColor : unselectedColor;

    return Expanded(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: ScaleTransition(
          scale: _scaleAnimation.drive(
            Tween<double>(begin: 1.0, end: 1.0),
          ).drive(CurveTween(curve: Curves.easeOut)),
          child: Semantics(
            label: widget.item.semanticLabel ?? widget.item.label,
            button: true,
            selected: widget.isSelected,
            child: AnimatedContainer(
              duration: GBTAnimations.normal,
              curve: GBTAnimations.defaultCurve,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // EN: Animated selection pill indicator
                  // KO: 애니메이션 선택 필 인디케이터
                  AnimatedContainer(
                    duration: GBTAnimations.normal,
                    curve: GBTAnimations.defaultCurve,
                    height: 28,
                    width: widget.isSelected ? 56 : 28,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? (widget.isDark
                              ? GBTColors.darkSurfaceElevated
                              : GBTColors.primary.withValues(alpha: 0.08))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        GBTSpacing.radiusFull,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: GBTAnimations.fast,
                      child: Icon(
                        widget.isSelected
                            ? widget.item.activeIcon
                            : widget.item.icon,
                        key: ValueKey(widget.isSelected),
                        color: color,
                        size: widget.isSelected ? 22 : 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: GBTAnimations.normal,
                    curve: GBTAnimations.defaultCurve,
                    style: GBTTypography.labelSmall.copyWith(
                      color: color,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: widget.isSelected ? 11 : 10,
                    ),
                    child: Text(widget.item.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
