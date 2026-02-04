/// EN: GBT (Girls Band Tabi) color system based on KT UXD design system
/// KO: KT UXD 디자인 시스템 기반 GBT (Girls Band Tabi) 색상 시스템
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// EN: Primary color palette for the application
/// KO: 앱의 기본 색상 팔레트
class GBTColors {
  GBTColors._();

  // ========================================
  // EN: Primary Brand Colors
  // KO: 기본 브랜드 색상
  // ========================================
  static const Color primary = Color(0xFF1A1A1A);
  static const Color primaryHover = Color(0xFF333333);
  static const Color primaryPressed = Color(0xFF000000);

  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryHover = Color(0xFFE55A2B);
  static const Color secondaryPressed = Color(0xFFCC4F25);

  // ========================================
  // EN: Accent Colors (Music/Fandom themed)
  // KO: 강조 색상 (음악/팬덤 테마)
  // ========================================
  static const Color accent = Color(0xFF6B46C1); // Purple - music
  static const Color accentPink = Color(0xFFEC4899); // Pink - girl groups
  static const Color accentBlue = Color(0xFF3B82F6); // Blue - information

  // ========================================
  // EN: Text Colors
  // KO: 텍스트 색상
  // ========================================
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF404040);
  static const Color textTertiary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ========================================
  // EN: Surface Colors
  // KO: 표면 색상
  // ========================================
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9F9F9);
  static const Color surfaceAlternate = Color(0xFFF5F5F5);

  // ========================================
  // EN: Border & Divider Colors
  // KO: 테두리 및 구분선 색상
  // ========================================
  static const Color border = Color(0xFFEBEBEB);
  static const Color borderFocused = Color(0xFF1A1A1A);
  static const Color divider = Color(0xFFE0E0E0);

  // ========================================
  // EN: Semantic Colors (Status)
  // KO: 의미적 색상 (상태)
  // ========================================
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ========================================
  // EN: Dark Mode Colors
  // KO: 다크 모드 색상
  // ========================================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);
  static const Color darkBorder = Color(0xFF2A2A2A);

  // ========================================
  // EN: Interactive Colors
  // KO: 인터랙티브 색상
  // ========================================
  static const Color ripple = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0x52000000);

  // ========================================
  // EN: Special Purpose Colors
  // KO: 특수 목적 색상
  // ========================================
  static const Color favorite = Color(0xFFEF4444); // Heart/favorite
  static const Color verified = Color(0xFF10B981); // Verified badge
  static const Color live = Color(0xFFEF4444); // Live indicator
  static const Color rating = Color(0xFFF59E0B); // Star rating

  // ========================================
  // EN: Gradient Definitions
  // KO: 그라디언트 정의
  // ========================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF333333)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0x80000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// EN: Color accessibility validator for WCAG compliance
/// KO: WCAG 준수를 위한 색상 접근성 검증기
class GBTColorValidator {
  GBTColorValidator._();

  /// EN: Check if color pair has valid contrast ratio (WCAG AA: 4.5:1)
  /// KO: 색상 쌍이 유효한 대비율을 가지는지 확인 (WCAG AA: 4.5:1)
  static bool hasValidContrast(
    Color foreground,
    Color background, {
    double minimumRatio = 4.5,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    return ratio >= minimumRatio;
  }

  /// EN: Calculate contrast ratio between two colors
  /// KO: 두 색상 간의 대비율 계산
  static double calculateContrastRatio(Color color1, Color color2) {
    final l1 = color1.computeLuminance();
    final l2 = color2.computeLuminance();
    final brightest = math.max(l1, l2);
    final darkest = math.min(l1, l2);
    return (brightest + 0.05) / (darkest + 0.05);
  }

  /// EN: Get contrasting text color for given background
  /// KO: 주어진 배경에 대한 대비 텍스트 색상 반환
  static Color getContrastingTextColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? GBTColors.textPrimary : GBTColors.textInverse;
  }
}

/// EN: Extension for color manipulation
/// KO: 색상 조작을 위한 확장
extension GBTColorExtension on Color {
  /// EN: Create color with opacity (using withValues for Flutter 3.27+ compatibility)
  /// KO: 불투명도가 적용된 색상 생성 (Flutter 3.27+ 호환성을 위해 withValues 사용)
  Color withOpacityValue(double opacity) => withValues(alpha: opacity);

  /// EN: Lighten color by percentage
  /// KO: 백분율만큼 색상 밝게
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// EN: Darken color by percentage
  /// KO: 백분율만큼 색상 어둡게
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
