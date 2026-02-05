/// EN: GBT Button component with multiple variants and press animation
/// KO: 다양한 변형과 프레스 애니메이션을 지원하는 GBT 버튼 컴포넌트
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_decorations.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

/// EN: Button variant enumeration
/// KO: 버튼 변형 열거형
enum GBTButtonVariant {
  /// EN: Primary filled button
  /// KO: 기본 채움 버튼
  primary,

  /// EN: Secondary outlined button
  /// KO: 보조 외곽선 버튼
  secondary,

  /// EN: Tertiary text button
  /// KO: 3차 텍스트 버튼
  tertiary,

  /// EN: Accent colored button
  /// KO: 강조 색상 버튼
  accent,

  /// EN: Danger/error button
  /// KO: 위험/오류 버튼
  danger,
}

/// EN: Button size enumeration
/// KO: 버튼 크기 열거형
enum GBTButtonSize { small, medium, large }

/// EN: GBT Button widget with press animation and accessibility support
/// KO: 프레스 애니메이션과 접근성을 지원하는 GBT 버튼 위젯
class GBTButton extends StatefulWidget {
  const GBTButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = GBTButtonVariant.primary,
    this.size = GBTButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticLabel,
  });

  /// EN: Button label text
  /// KO: 버튼 라벨 텍스트
  final String label;

  /// EN: Callback when button is pressed
  /// KO: 버튼이 눌렸을 때 콜백
  final VoidCallback? onPressed;

  /// EN: Button visual variant
  /// KO: 버튼 시각적 변형
  final GBTButtonVariant variant;

  /// EN: Button size
  /// KO: 버튼 크기
  final GBTButtonSize size;

  /// EN: Optional leading or trailing icon
  /// KO: 선택적 앞 또는 뒤 아이콘
  final IconData? icon;

  /// EN: Icon position (leading or trailing)
  /// KO: 아이콘 위치 (앞 또는 뒤)
  final IconPosition iconPosition;

  /// EN: Loading state
  /// KO: 로딩 상태
  final bool isLoading;

  /// EN: Whether button should fill available width
  /// KO: 버튼이 사용 가능한 너비를 채울지 여부
  final bool isFullWidth;

  /// EN: Semantic label for accessibility
  /// KO: 접근성을 위한 시맨틱 라벨
  final String? semanticLabel;

  @override
  State<GBTButton> createState() => _GBTButtonState();
}

class _GBTButtonState extends State<GBTButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: GBTAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: GBTAnimations.pressedScale,
    ).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (_isEnabled) _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final child = _buildChild();

    Widget button = switch (widget.variant) {
      GBTButtonVariant.primary ||
      GBTButtonVariant.accent ||
      GBTButtonVariant.danger => ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: buttonStyle,
        child: child,
      ),
      GBTButtonVariant.secondary => OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: buttonStyle,
        child: child,
      ),
      GBTButtonVariant.tertiary => TextButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: buttonStyle,
        child: child,
      ),
    };

    if (widget.isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      enabled: _isEnabled,
      child: GestureDetector(
        onTapDown: _isEnabled ? _onTapDown : null,
        onTapUp: _isEnabled ? _onTapUp : null,
        onTapCancel: _isEnabled ? _onTapCancel : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: button,
        ),
      ),
    );
  }

  /// EN: Build button child with animated loading transition
  /// KO: 애니메이션 로딩 전환이 있는 버튼 자식 빌드
  Widget _buildChild() {
    return AnimatedSwitcher(
      duration: GBTAnimations.fast,
      child: widget.isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: _getIconSize(),
              height: _getIconSize(),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_getForegroundColor()),
              ),
            )
          : _buildContent(),
    );
  }

  /// EN: Build button content (text + optional icon)
  /// KO: 버튼 콘텐츠 빌드 (텍스트 + 선택적 아이콘)
  Widget _buildContent() {
    if (widget.icon != null) {
      final iconWidget = Icon(widget.icon, size: _getIconSize());
      final spacing = SizedBox(width: GBTSpacing.sm);

      if (widget.iconPosition == IconPosition.leading) {
        return Row(
          key: const ValueKey('content'),
          mainAxisSize: MainAxisSize.min,
          children: [iconWidget, spacing, Text(widget.label)],
        );
      } else {
        return Row(
          key: const ValueKey('content'),
          mainAxisSize: MainAxisSize.min,
          children: [Text(widget.label), spacing, iconWidget],
        );
      }
    }

    return Text(widget.label, key: const ValueKey('content'));
  }

  /// EN: Get button style based on variant
  /// KO: 변형에 따른 버튼 스타일 반환
  ButtonStyle _getButtonStyle() {
    final padding = _getPadding();
    final minimumSize = _getMinimumSize();

    return switch (widget.variant) {
      GBTButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: GBTColors.primary,
        foregroundColor: GBTColors.textInverse,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _getTextStyle(),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
      ),
      GBTButtonVariant.accent => ElevatedButton.styleFrom(
        backgroundColor: GBTColors.accent,
        foregroundColor: GBTColors.textInverse,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _getTextStyle(),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
      ),
      GBTButtonVariant.danger => ElevatedButton.styleFrom(
        backgroundColor: GBTColors.error,
        foregroundColor: GBTColors.textInverse,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _getTextStyle(),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
      ),
      GBTButtonVariant.secondary => OutlinedButton.styleFrom(
        foregroundColor: GBTColors.primary,
        padding: padding,
        minimumSize: minimumSize,
        side: const BorderSide(color: GBTColors.border),
        textStyle: _getTextStyle(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
      ),
      GBTButtonVariant.tertiary => TextButton.styleFrom(
        foregroundColor: GBTColors.primary,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _getTextStyle(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
      ),
    };
  }

  /// EN: Get foreground color for loading indicator
  /// KO: 로딩 인디케이터용 전경색 반환
  Color _getForegroundColor() {
    return switch (widget.variant) {
      GBTButtonVariant.primary ||
      GBTButtonVariant.accent ||
      GBTButtonVariant.danger => GBTColors.textInverse,
      GBTButtonVariant.secondary ||
      GBTButtonVariant.tertiary => GBTColors.primary,
    };
  }

  /// EN: Get padding based on size
  /// KO: 크기에 따른 패딩 반환
  EdgeInsets _getPadding() {
    return switch (widget.size) {
      GBTButtonSize.small => const EdgeInsets.symmetric(
        horizontal: GBTSpacing.md,
        vertical: GBTSpacing.xs,
      ),
      GBTButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: GBTSpacing.lg,
        vertical: GBTSpacing.sm,
      ),
      GBTButtonSize.large => const EdgeInsets.symmetric(
        horizontal: GBTSpacing.xl,
        vertical: GBTSpacing.md,
      ),
    };
  }

  /// EN: Get minimum size based on size
  /// KO: 크기에 따른 최소 크기 반환
  Size _getMinimumSize() {
    return switch (widget.size) {
      GBTButtonSize.small => const Size(64, 32),
      GBTButtonSize.medium => const Size(88, GBTSpacing.minTouchTarget),
      GBTButtonSize.large => const Size(120, GBTSpacing.touchTarget),
    };
  }

  /// EN: Get text style based on size
  /// KO: 크기에 따른 텍스트 스타일 반환
  TextStyle _getTextStyle() {
    return switch (widget.size) {
      GBTButtonSize.small => GBTTypography.labelMedium,
      GBTButtonSize.medium => GBTTypography.button,
      GBTButtonSize.large => GBTTypography.button.copyWith(fontSize: 16),
    };
  }

  /// EN: Get icon size based on button size
  /// KO: 버튼 크기에 따른 아이콘 크기 반환
  double _getIconSize() {
    return switch (widget.size) {
      GBTButtonSize.small => 16,
      GBTButtonSize.medium => 20,
      GBTButtonSize.large => 24,
    };
  }
}

/// EN: Icon position enumeration
/// KO: 아이콘 위치 열거형
enum IconPosition { leading, trailing }

/// EN: Icon-only button widget with press animation
/// KO: 프레스 애니메이션이 있는 아이콘 전용 버튼 위젯
class GBTIconButton extends StatefulWidget {
  const GBTIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = GBTButtonSize.medium,
    this.variant = GBTButtonVariant.tertiary,
    this.semanticLabel,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final GBTButtonSize size;
  final GBTButtonVariant variant;
  final String? semanticLabel;
  final String? tooltip;

  @override
  State<GBTIconButton> createState() => _GBTIconButtonState();
}

class _GBTIconButtonState extends State<GBTIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: GBTAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;

    final buttonSize = switch (widget.size) {
      GBTButtonSize.small => 32.0,
      GBTButtonSize.medium => 40.0,
      GBTButtonSize.large => 48.0,
    };

    final iconSize = switch (widget.size) {
      GBTButtonSize.small => 16.0,
      GBTButtonSize.medium => 24.0,
      GBTButtonSize.large => 28.0,
    };

    final color = switch (widget.variant) {
      GBTButtonVariant.primary => isDark
          ? GBTColors.darkTextPrimary
          : GBTColors.primary,
      GBTButtonVariant.secondary => isDark
          ? GBTColors.darkTextSecondary
          : GBTColors.textSecondary,
      GBTButtonVariant.tertiary => isDark
          ? GBTColors.darkTextTertiary
          : GBTColors.textTertiary,
      GBTButtonVariant.accent => GBTColors.accent,
      GBTButtonVariant.danger => GBTColors.error,
    };

    Widget button = Semantics(
      button: true,
      label: widget.semanticLabel,
      enabled: isEnabled,
      child: GestureDetector(
        onTapDown: isEnabled
            ? (_) => _pressController.forward()
            : null,
        onTapUp: isEnabled
            ? (_) => _pressController.reverse()
            : null,
        onTapCancel: isEnabled ? () => _pressController.reverse() : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: IconButton(
              icon: Icon(widget.icon, size: iconSize),
              onPressed: widget.onPressed != null
                  ? () {
                      HapticFeedback.selectionClick();
                      widget.onPressed!();
                    }
                  : null,
              color: color,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: buttonSize,
                minHeight: buttonSize,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
