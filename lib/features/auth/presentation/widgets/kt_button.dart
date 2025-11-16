import 'package:flutter/material.dart';

import '../../../../core/theme/kt_colors.dart';
import '../../../../core/theme/kt_spacing.dart';
import '../../../../core/theme/kt_typography.dart';

/// EN: KT UXD design system button widget with multiple variants
/// KO: 여러 변형을 가진 KT UXD 디자인 시스템 버튼 위젯
class KTButton extends StatelessWidget {
  /// EN: Creates a KT UXD button
  /// KO: KT UXD 버튼 생성
  const KTButton._({
    super.key,
    required this.onPressed,
    required this.child,
    required this.variant,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.size = KTButtonSize.medium,
    this.fullWidth = false,
    this.borderRadius,
  });

  /// EN: Creates a primary button with filled background
  /// KO: 채워진 배경을 가진 기본 버튼 생성
  factory KTButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    bool loading = false,
    bool disabled = false,
    IconData? icon,
    KTButtonSize size = KTButtonSize.medium,
    bool fullWidth = false,
    BorderRadius? borderRadius,
  }) {
    return KTButton._(
      key: key,
      onPressed: onPressed,
      child: child,
      variant: _KTButtonVariant.primary,
      loading: loading,
      disabled: disabled,
      icon: icon,
      size: size,
      fullWidth: fullWidth,
      borderRadius: borderRadius,
    );
  }

  /// EN: Creates a secondary button with subtle background
  /// KO: 미묘한 배경을 가진 보조 버튼 생성
  factory KTButton.secondary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    bool loading = false,
    bool disabled = false,
    IconData? icon,
    KTButtonSize size = KTButtonSize.medium,
    bool fullWidth = false,
    BorderRadius? borderRadius,
  }) {
    return KTButton._(
      key: key,
      onPressed: onPressed,
      child: child,
      variant: _KTButtonVariant.secondary,
      loading: loading,
      disabled: disabled,
      icon: icon,
      size: size,
      fullWidth: fullWidth,
      borderRadius: borderRadius,
    );
  }

  /// EN: Creates an outlined button with border
  /// KO: 경계선을 가진 아웃라인 버튼 생성
  factory KTButton.outlined({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    bool loading = false,
    bool disabled = false,
    IconData? icon,
    KTButtonSize size = KTButtonSize.medium,
    bool fullWidth = false,
    BorderRadius? borderRadius,
  }) {
    return KTButton._(
      key: key,
      onPressed: onPressed,
      child: child,
      variant: _KTButtonVariant.outlined,
      loading: loading,
      disabled: disabled,
      icon: icon,
      size: size,
      fullWidth: fullWidth,
      borderRadius: borderRadius,
    );
  }

  /// EN: Creates a text-only button
  /// KO: 텍스트만 있는 버튼 생성
  factory KTButton.text({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    bool loading = false,
    bool disabled = false,
    IconData? icon,
    KTButtonSize size = KTButtonSize.medium,
    bool fullWidth = false,
    BorderRadius? borderRadius,
  }) {
    return KTButton._(
      key: key,
      onPressed: onPressed,
      child: child,
      variant: _KTButtonVariant.text,
      loading: loading,
      disabled: disabled,
      icon: icon,
      size: size,
      fullWidth: fullWidth,
      borderRadius: borderRadius,
    );
  }

  /// EN: Button press callback
  /// KO: 버튼 눌림 콜백
  final VoidCallback? onPressed;

  /// EN: Button content widget
  /// KO: 버튼 내용 위젯
  final Widget child;

  /// EN: Button style variant
  /// KO: 버튼 스타일 변형
  final _KTButtonVariant variant;

  /// EN: Whether button is in loading state
  /// KO: 버튼이 로딩 상태인지 여부
  final bool loading;

  /// EN: Whether button is disabled
  /// KO: 버튼이 비활성화되었는지 여부
  final bool disabled;

  /// EN: Optional icon to show before text
  /// KO: 텍스트 앞에 표시할 선택적 아이콘
  final IconData? icon;

  /// EN: Button size variant
  /// KO: 버튼 크기 변형
  final KTButtonSize size;

  /// EN: Whether button should take full width
  /// KO: 버튼이 전체 너비를 차지해야 하는지 여부
  final bool fullWidth;

  /// EN: Custom border radius
  /// KO: 사용자 정의 경계 반지름
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading || onPressed == null;
    final buttonStyle = _getButtonStyle(isDisabled);
    final contentWidget = _buildContent();

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: buttonStyle,
        child: contentWidget,
      ),
    );
  }

  /// EN: Get button style based on variant and state
  /// KO: 변형과 상태에 따른 버튼 스타일 가져오기
  ButtonStyle _getButtonStyle(bool isDisabled) {
    final radius = borderRadius ?? 
                  BorderRadius.circular(KTSpacing.borderRadiusSmall);

    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (isDisabled) {
          return _getDisabledBackgroundColor();
        }
        if (states.contains(MaterialState.pressed)) {
          return _getPressedBackgroundColor();
        }
        if (states.contains(MaterialState.hovered)) {
          return _getHoveredBackgroundColor();
        }
        return _getBackgroundColor();
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (isDisabled) {
          return _getDisabledForegroundColor();
        }
        return _getForegroundColor();
      }),
      overlayColor: MaterialStateProperty.all(_getOverlayColor()),
      elevation: MaterialStateProperty.all(_getElevation()),
      shadowColor: MaterialStateProperty.all(KTColors.cardShadow),
      side: MaterialStateProperty.resolveWith((states) {
        if (variant == _KTButtonVariant.outlined) {
          final borderColor = isDisabled 
              ? KTColors.borderColorLight 
              : KTColors.borderColor;
          return BorderSide(color: borderColor, width: 1);
        }
        return null;
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: radius),
      ),
      padding: MaterialStateProperty.all(_getPadding()),
      minimumSize: MaterialStateProperty.all(_getMinimumSize()),
      textStyle: MaterialStateProperty.all(_getTextStyle()),
    );
  }

  /// EN: Build button content with loading indicator and icon
  /// KO: 로딩 인디케이터와 아이콘을 포함한 버튼 내용 구성
  Widget _buildContent() {
    if (loading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getForegroundColor()),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: KTSpacing.xs),
          Flexible(child: child),
        ],
      );
    }

    return child;
  }

  // EN: Style getters based on variant
  // KO: 변형에 따른 스타일 게터

  Color _getBackgroundColor() {
    return switch (variant) {
      _KTButtonVariant.primary => KTColors.buttonPrimary,
      _KTButtonVariant.secondary => KTColors.surfaceAlternate,
      _KTButtonVariant.outlined => Colors.transparent,
      _KTButtonVariant.text => Colors.transparent,
    };
  }

  Color _getHoveredBackgroundColor() {
    return switch (variant) {
      _KTButtonVariant.primary => KTColors.primaryTextLight,
      _KTButtonVariant.secondary => KTColors.surface,
      _KTButtonVariant.outlined => KTColors.surface.withOpacity(0.05),
      _KTButtonVariant.text => KTColors.surface.withOpacity(0.05),
    };
  }

  Color _getPressedBackgroundColor() {
    return switch (variant) {
      _KTButtonVariant.primary => KTColors.primaryTextDark,
      _KTButtonVariant.secondary => KTColors.borderColor,
      _KTButtonVariant.outlined => KTColors.surface.withOpacity(0.1),
      _KTButtonVariant.text => KTColors.surface.withOpacity(0.1),
    };
  }

  Color _getDisabledBackgroundColor() {
    return switch (variant) {
      _KTButtonVariant.primary => KTColors.borderColor,
      _KTButtonVariant.secondary => KTColors.borderColor,
      _KTButtonVariant.outlined => Colors.transparent,
      _KTButtonVariant.text => Colors.transparent,
    };
  }

  Color _getForegroundColor() {
    return switch (variant) {
      _KTButtonVariant.primary => KTColors.background,
      _KTButtonVariant.secondary => KTColors.primaryText,
      _KTButtonVariant.outlined => KTColors.primaryText,
      _KTButtonVariant.text => KTColors.primaryText,
    };
  }

  Color _getDisabledForegroundColor() {
    return KTColors.secondaryText;
  }

  Color _getOverlayColor() {
    return switch (variant) {
      _KTButtonVariant.primary => KTColors.background.withOpacity(0.1),
      _ => KTColors.primaryText.withOpacity(0.05),
    };
  }

  double _getElevation() {
    return switch (variant) {
      _KTButtonVariant.primary => KTSpacing.elevationLow,
      _ => KTSpacing.elevationNone,
    };
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      KTButtonSize.small => const EdgeInsets.symmetric(
          horizontal: KTSpacing.sm, vertical: KTSpacing.xs),
      KTButtonSize.medium => const EdgeInsets.symmetric(
          horizontal: KTSpacing.lg, vertical: KTSpacing.md),
      KTButtonSize.large => const EdgeInsets.symmetric(
          horizontal: KTSpacing.xl, vertical: KTSpacing.lg),
    };
  }

  Size _getMinimumSize() {
    return switch (size) {
      KTButtonSize.small => const Size(80, 32),
      KTButtonSize.medium => const Size(120, KTSpacing.touchTarget),
      KTButtonSize.large => const Size(140, 56),
    };
  }

  double _getHeight() {
    return switch (size) {
      KTButtonSize.small => 32,
      KTButtonSize.medium => KTSpacing.touchTarget,
      KTButtonSize.large => 56,
    };
  }

  TextStyle _getTextStyle() {
    final baseStyle = switch (size) {
      KTButtonSize.small => KTTypography.labelMedium,
      KTButtonSize.medium => KTTypography.button,
      KTButtonSize.large => KTTypography.titleMedium,
    };

    return baseStyle.copyWith(fontWeight: FontWeight.w600);
  }

  double _getIconSize() {
    return switch (size) {
      KTButtonSize.small => 16,
      KTButtonSize.medium => 20,
      KTButtonSize.large => 24,
    };
  }

  double _getLoadingSize() {
    return switch (size) {
      KTButtonSize.small => 12,
      KTButtonSize.medium => 16,
      KTButtonSize.large => 20,
    };
  }
}

/// EN: Button size variants
/// KO: 버튼 크기 변형
enum KTButtonSize {
  /// EN: Small button for compact spaces
  /// KO: 컴팩트 공간용 작은 버튼
  small,
  
  /// EN: Medium button for standard use
  /// KO: 표준 사용을 위한 중간 버튼
  medium,
  
  /// EN: Large button for prominence
  /// KO: 강조용 큰 버튼
  large,
}

/// EN: Internal button variant enum
/// KO: 내부 버튼 변형 열거형
enum _KTButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}