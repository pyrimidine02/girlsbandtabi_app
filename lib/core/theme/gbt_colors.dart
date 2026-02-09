/// EN: GBT (Girls Band Tabi) color system — vibrant music fandom palette
/// KO: GBT (Girls Band Tabi) 색상 시스템 — 활기찬 음악 팬덤 팔레트
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// EN: Primary color palette for the application
/// KO: 앱의 기본 색상 팔레트
class GBTColors {
  GBTColors._();

  // ========================================
  // EN: Primary Brand Colors (Purple — music/creativity)
  // KO: 기본 브랜드 색상 (보라 — 음악/창의성)
  // ========================================
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primaryHover = Color(0xFF6D28D9);
  static const Color primaryPressed = Color(0xFF5B21B6);
  static const Color primaryMuted = Color(0xFFA78BFA);

  // EN: Secondary (Pink — girl group energy)
  // KO: 보조 (핑크 — 걸그룹 에너지)
  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryLight = Color(0xFFFCE7F3);
  static const Color secondaryHover = Color(0xFFDB2777);
  static const Color secondaryPressed = Color(0xFFBE185D);

  // ========================================
  // EN: Accent Colors (Music/Fandom themed)
  // KO: 강조 색상 (음악/팬덤 테마)
  // ========================================
  static const Color accent = Color(0xFFF59E0B); // Amber — highlights
  static const Color accentBlue = Color(0xFF3B82F6); // Blue — information
  static const Color accentTeal = Color(0xFF14B8A6); // Teal — visits/places

  // ========================================
  // EN: Text Colors
  // KO: 텍스트 색상
  // ========================================
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A4A68);
  static const Color textTertiary = Color(0xFF7C7C9A);
  static const Color textDisabled = Color(0xFFA8A8C0);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ========================================
  // EN: Surface Colors
  // KO: 표면 색상
  // ========================================
  static const Color background = Color(0xFFFAFAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F4F8);
  static const Color surfaceAlternate = Color(0xFFEFEFF5);

  // ========================================
  // EN: Border & Divider Colors
  // KO: 테두리 및 구분선 색상
  // ========================================
  static const Color border = Color(0xFFE5E5EF);
  static const Color borderFocused = Color(0xFF7C3AED);
  static const Color divider = Color(0xFFE0E0EA);

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
  static const Color darkBackground = Color(0xFF0C0C18);
  static const Color darkSurface = Color(0xFF161628);
  static const Color darkSurfaceVariant = Color(0xFF1E1E36);
  static const Color darkSurfaceElevated = Color(0xFF282848);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFB8B8D0);
  // EN: Passes WCAG AA (4.5:1) on darkSurface.
  // KO: darkSurface 위에서 WCAG AA(4.5:1) 충족.
  static const Color darkTextTertiary = Color(0xFF9090A8);
  // EN: Dark primary purple — lighter for WCAG AA compliance.
  // KO: 다크 모드 기본 보라색 — WCAG AA 준수를 위해 밝게.
  static const Color darkPrimary = Color(0xFFA78BFA);
  static const Color darkSecondary = Color(0xFFF472B6);
  static const Color darkAccent = Color(0xFFFBBF24);
  static const Color darkBorder = Color(0xFF2D2D50);
  static const Color darkBorderSubtle = Color(0xFF222240);

  // ========================================
  // EN: Interactive Colors
  // KO: 인터랙티브 색상
  // ========================================
  static const Color ripple = Color(0x147C3AED);
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0x52000000);

  // ========================================
  // EN: Special Purpose Colors
  // KO: 특수 목적 색상
  // ========================================
  static const Color favorite = Color(0xFFEF4444);
  static const Color verified = Color(0xFF10B981);
  static const Color live = Color(0xFFEF4444);
  static const Color rating = Color(0xFFF59E0B);

  // ========================================
  // EN: Gradient Definitions
  // KO: 그라디언트 정의
  // ========================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // EN: Secondary pink gradient for girl group themed elements
  // KO: 걸그룹 테마 요소를 위한 보조 핑크 그라디언트
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // EN: Dark mode gradient with deeper, richer colors
  // KO: 다크 모드용 더 깊고 풍부한 색상의 그라디언트
  static const LinearGradient darkAccentGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // EN: Subtle surface gradient for elevated dark surfaces
  // KO: 다크 모드 높은 표면을 위한 미세한 표면 그라디언트
  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [darkSurface, darkSurfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0x99000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // EN: Shimmer gradient for loading placeholders
  // KO: 로딩 플레이스홀더를 위한 쉬머 그라디언트
  static const Color shimmerBase = Color(0xFFE8E8F0);
  static const Color shimmerHighlight = Color(0xFFF5F5FA);
  static const Color darkShimmerBase = Color(0xFF1E1E36);
  static const Color darkShimmerHighlight = Color(0xFF2D2D50);
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
