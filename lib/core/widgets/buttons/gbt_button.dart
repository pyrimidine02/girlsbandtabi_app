/// EN: GBT Button component with multiple variants
/// KO: 다양한 변형을 지원하는 GBT 버튼 컴포넌트
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
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

/// EN: GBT Button widget with accessibility support
/// KO: 접근성을 지원하는 GBT 버튼 위젯
class GBTButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final child = _buildChild();

    Widget button = switch (variant) {
      GBTButtonVariant.primary ||
      GBTButtonVariant.accent ||
      GBTButtonVariant.danger => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      ),
      GBTButtonVariant.secondary => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      ),
      GBTButtonVariant.tertiary => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      ),
    };

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: onPressed != null && !isLoading,
      child: button,
    );
  }

  /// EN: Build button child content
  /// KO: 버튼 자식 콘텐츠 빌드
  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getForegroundColor()),
        ),
      );
    }

    if (icon != null) {
      final iconWidget = Icon(icon, size: _getIconSize());
      final spacing = SizedBox(width: GBTSpacing.sm);

      if (iconPosition == IconPosition.leading) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [iconWidget, spacing, Text(label)],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text(label), spacing, iconWidget],
        );
      }
    }

    return Text(label);
  }

  /// EN: Get button style based on variant
  /// KO: 변형에 따른 버튼 스타일 반환
  ButtonStyle _getButtonStyle() {
    final padding = _getPadding();
    final minimumSize = _getMinimumSize();

    return switch (variant) {
      GBTButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: GBTColors.primary,
        foregroundColor: GBTColors.textInverse,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _getTextStyle(),
      ),
      GBTButtonVariant.accent => ElevatedButton.styleFrom(
        backgroundColor: GBTColors.accent,
        foregroundColor: GBTColors.textInverse,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _getTextStyle(),
      ),
      GBTButtonVariant.danger => ElevatedButton.styleFrom(
        backgroundColor: GBTColors.error,
        foregroundColor: GBTColors.textInverse,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _getTextStyle(),
      ),
      GBTButtonVariant.secondary => OutlinedButton.styleFrom(
        foregroundColor: GBTColors.primary,
        padding: padding,
        minimumSize: minimumSize,
        side: const BorderSide(color: GBTColors.border),
        textStyle: _getTextStyle(),
      ),
      GBTButtonVariant.tertiary => TextButton.styleFrom(
        foregroundColor: GBTColors.primary,
        padding: padding,
        minimumSize: minimumSize,
        textStyle: _getTextStyle(),
      ),
    };
  }

  /// EN: Get foreground color for loading indicator
  /// KO: 로딩 인디케이터용 전경색 반환
  Color _getForegroundColor() {
    return switch (variant) {
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
    return switch (size) {
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
    return switch (size) {
      GBTButtonSize.small => const Size(64, 32),
      GBTButtonSize.medium => const Size(88, GBTSpacing.minTouchTarget),
      GBTButtonSize.large => const Size(120, GBTSpacing.touchTarget),
    };
  }

  /// EN: Get text style based on size
  /// KO: 크기에 따른 텍스트 스타일 반환
  TextStyle _getTextStyle() {
    return switch (size) {
      GBTButtonSize.small => GBTTypography.labelMedium,
      GBTButtonSize.medium => GBTTypography.button,
      GBTButtonSize.large => GBTTypography.button.copyWith(fontSize: 16),
    };
  }

  /// EN: Get icon size based on button size
  /// KO: 버튼 크기에 따른 아이콘 크기 반환
  double _getIconSize() {
    return switch (size) {
      GBTButtonSize.small => 16,
      GBTButtonSize.medium => 20,
      GBTButtonSize.large => 24,
    };
  }
}

/// EN: Icon position enumeration
/// KO: 아이콘 위치 열거형
enum IconPosition { leading, trailing }

/// EN: Icon-only button widget
/// KO: 아이콘 전용 버튼 위젯
class GBTIconButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final buttonSize = switch (size) {
      GBTButtonSize.small => 32.0,
      GBTButtonSize.medium => 40.0,
      GBTButtonSize.large => 48.0,
    };

    final iconSize = switch (size) {
      GBTButtonSize.small => 16.0,
      GBTButtonSize.medium => 24.0,
      GBTButtonSize.large => 28.0,
    };

    final color = switch (variant) {
      GBTButtonVariant.primary => GBTColors.primary,
      GBTButtonVariant.secondary => GBTColors.textSecondary,
      GBTButtonVariant.tertiary => GBTColors.textTertiary,
      GBTButtonVariant.accent => GBTColors.accent,
      GBTButtonVariant.danger => GBTColors.error,
    };

    Widget button = Semantics(
      button: true,
      label: semanticLabel,
      enabled: onPressed != null,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: IconButton(
          icon: Icon(icon, size: iconSize),
          onPressed: onPressed,
          color: color,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: buttonSize,
            minHeight: buttonSize,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
