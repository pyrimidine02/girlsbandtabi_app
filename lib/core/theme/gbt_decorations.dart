/// EN: GBT decoration system for consistent shadows, borders, and surfaces
/// KO: 일관된 그림자, 테두리, 표면을 위한 GBT 데코레이션 시스템
library;

import 'package:flutter/material.dart';

import 'gbt_colors.dart';
import 'gbt_spacing.dart';

/// EN: Consistent box shadow presets
/// KO: 일관된 박스 그림자 프리셋
class GBTShadows {
  GBTShadows._();

  // ========================================
  // EN: Light Mode Shadows
  // KO: 라이트 모드 그림자
  // ========================================

  /// EN: Subtle shadow for cards at rest
  /// KO: 정지 상태 카드를 위한 미세한 그림자
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// EN: Medium shadow for elevated elements
  /// KO: 높은 요소를 위한 중간 그림자
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// EN: Large shadow for modals/sheets
  /// KO: 모달/시트를 위한 큰 그림자
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  /// EN: Extra large shadow for floating elements
  /// KO: 플로팅 요소를 위한 초대형 그림자
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 48,
      offset: Offset(0, 16),
    ),
  ];

  /// EN: Colored glow shadow for accent elements
  /// KO: 강조 요소를 위한 색상 글로우 그림자
  static List<BoxShadow> accentGlow({double opacity = 0.25}) => [
    BoxShadow(
      color: GBTColors.accent.withValues(alpha: opacity),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// EN: Secondary color glow
  /// KO: 보조 색상 글로우
  static List<BoxShadow> secondaryGlow({double opacity = 0.25}) => [
    BoxShadow(
      color: GBTColors.secondary.withValues(alpha: opacity),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ========================================
  // EN: Dark Mode Shadows (using colored glows)
  // KO: 다크 모드 그림자 (색상 글로우 사용)
  // ========================================

  /// EN: Subtle border glow for dark mode cards
  /// KO: 다크 모드 카드를 위한 미세한 테두리 글로우
  static const List<BoxShadow> darkSm = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// EN: Medium glow for dark mode
  /// KO: 다크 모드를 위한 중간 글로우
  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// EN: Large glow for dark mode modals
  /// KO: 다크 모드 모달을 위한 큰 글로우
  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

/// EN: Consistent decoration presets for cards, containers, surfaces
/// KO: 카드, 컨테이너, 표면을 위한 일관된 데코레이션 프리셋
class GBTDecorations {
  GBTDecorations._();

  // ========================================
  // EN: Card Decorations
  // KO: 카드 데코레이션
  // ========================================

  /// EN: Default card decoration
  /// KO: 기본 카드 데코레이션
  static BoxDecoration card({bool isDark = false}) => BoxDecoration(
    color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surface,
    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
    boxShadow: isDark ? GBTShadows.darkSm : GBTShadows.sm,
    border: isDark
        ? Border.all(color: GBTColors.darkBorderSubtle, width: 0.5)
        : null,
  );

  /// EN: Elevated card decoration
  /// KO: 높은 카드 데코레이션
  static BoxDecoration cardElevated({bool isDark = false}) => BoxDecoration(
    color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface,
    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
    boxShadow: isDark ? GBTShadows.darkMd : GBTShadows.md,
    border: isDark
        ? Border.all(color: GBTColors.darkBorder, width: 0.5)
        : null,
  );

  // ========================================
  // EN: Surface Decorations
  // KO: 표면 데코레이션
  // ========================================

  /// EN: Subtle surface decoration
  /// KO: 미세한 표면 데코레이션
  static BoxDecoration surface({bool isDark = false}) => BoxDecoration(
    color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
    borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
  );

  /// EN: Interactive surface with border on hover/focus
  /// KO: 호버/포커스 시 테두리가 있는 인터랙티브 표면
  static BoxDecoration surfaceInteractive({
    bool isDark = false,
    bool isActive = false,
  }) => BoxDecoration(
    color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
    border: Border.all(
      color: isActive
          ? (isDark ? GBTColors.secondary : GBTColors.primary)
          : (isDark ? GBTColors.darkBorderSubtle : GBTColors.border),
      width: isActive ? 1.5 : 1,
    ),
  );

  // ========================================
  // EN: Badge Decorations
  // KO: 배지 데코레이션
  // ========================================

  /// EN: Live badge decoration
  /// KO: 라이브 배지 데코레이션
  static BoxDecoration liveBadge() => BoxDecoration(
    color: GBTColors.live,
    borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
    boxShadow: [
      BoxShadow(
        color: GBTColors.live.withValues(alpha: 0.4),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// EN: Verified badge decoration
  /// KO: 인증 배지 데코레이션
  static BoxDecoration verifiedBadge() => BoxDecoration(
    color: GBTColors.verified,
    borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
  );

  // ========================================
  // EN: Sheet / Modal Decorations
  // KO: 시트 / 모달 데코레이션
  // ========================================

  /// EN: Bottom sheet decoration
  /// KO: 바텀 시트 데코레이션
  static BoxDecoration bottomSheet({bool isDark = false}) => BoxDecoration(
    color: isDark ? GBTColors.darkSurface : GBTColors.surface,
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(GBTSpacing.radiusXl),
    ),
    boxShadow: isDark ? GBTShadows.darkLg : GBTShadows.lg,
  );
}

/// EN: Animation constants for consistent motion
/// KO: 일관된 모션을 위한 애니메이션 상수
class GBTAnimations {
  GBTAnimations._();

  // EN: Standard durations
  // KO: 표준 지속 시간
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration emphasis = Duration(milliseconds: 500);

  // EN: Standard curves
  // KO: 표준 커브
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve emphasizedCurve = Curves.easeInOutCubicEmphasized;

  // EN: Press animation scale factor
  // KO: 프레스 애니메이션 스케일 팩터
  static const double pressedScale = 0.97;
  static const double hoverScale = 1.02;
}
