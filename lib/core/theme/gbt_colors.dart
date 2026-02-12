/// EN: GBT (Girls Band Tabi) color system — neutral-first, brand-accent palette
/// KO: GBT (Girls Band Tabi) 색상 시스템 — 뉴트럴 기반, 브랜드 액센트 팔레트
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// EN: Primary color palette for the application
/// KO: 앱의 기본 색상 팔레트
class GBTColors {
  GBTColors._();

  // ========================================
  // EN: Primary Brand Colors (Pastel periwinkle — soft, friendly tone)
  // KO: 기본 브랜드 색상 (파스텔 페리윙클 — 부드러운 톤)
  // ========================================
  static const Color primary = Color(0xFFA6B1FF);
  static const Color primaryLight = Color(0xFFF0F2FF);
  static const Color primaryHover = Color(0xFF94A3FF);
  static const Color primaryPressed = Color(0xFF7F90FF);
  static const Color primaryMuted = Color(0xFFD9DFFF);

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
  // EN: Text Colors (pure neutral — no purple tint)
  // KO: 텍스트 색상 (순수 뉴트럴 — 보라 틴트 제거)
  // ========================================
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ========================================
  // EN: Surface Colors (pure neutral)
  // KO: 표면 색상 (순수 뉴트럴)
  // ========================================
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceAlternate = Color(0xFFEEEEEE);

  // ========================================
  // EN: Border & Divider Colors (neutral)
  // KO: 테두리 및 구분선 색상 (뉴트럴)
  // ========================================
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocused = primary;
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
  // EN: Dark Mode Colors (Spotify-style pure black OLED)
  // KO: 다크 모드 색상 (Spotify 스타일 순수 블랙 OLED)
  // ========================================
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E);
  static const Color darkSurfaceElevated = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  // EN: Passes WCAG AA (4.5:1) on darkSurface (#121212).
  // KO: darkSurface (#121212) 위에서 WCAG AA(4.5:1) 충족.
  static const Color darkTextTertiary = Color(0xFF808080);
  // EN: Dark primary pastel — light enough for dark surfaces.
  // KO: 다크 모드 기본 파스텔 — 다크 표면 위에서도 충분히 밝게.
  static const Color darkPrimary = Color(0xFFB8C2FF);
  static const Color darkSecondary = Color(0xFFF472B6);
  static const Color darkAccent = Color(0xFFFBBF24);
  static const Color darkBorder = Color(0xFF2C2C2C);
  static const Color darkBorderSubtle = Color(0xFF1E1E1E);

  // ========================================
  // EN: Interactive Colors
  // KO: 인터랙티브 색상
  // ========================================
  static const Color ripple = Color(0x14A6B1FF);
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
    colors: [primary, primaryHover],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // EN: Deprecated — use primaryGradient sparingly or solid colors instead.
  // KO: 더 이상 사용하지 않음 — primaryGradient를 최소한으로 또는 단색을 사용하세요.
  @Deprecated('Use primaryGradient or solid colors instead')
  static const LinearGradient accentGradient = primaryGradient;

  @Deprecated('Use solid secondary color instead')
  static const LinearGradient secondaryGradient = primaryGradient;

  @Deprecated('Use primaryGradient or solid colors instead')
  static const LinearGradient darkAccentGradient = primaryGradient;

  @Deprecated('Use solid darkSurface colors instead')
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

  /// EN: Greeting header gradient — solid indigo (light mode)
  /// KO: 인사말 헤더 그라디언트 — 단색 인디고 (라이트 모드)
  static const LinearGradient greetingGradient = LinearGradient(
    colors: [primary, primaryHover],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// EN: Greeting header gradient — solid deep indigo (dark mode)
  /// KO: 인사말 헤더 그라디언트 — 단색 딥 인디고 (다크 모드)
  static const LinearGradient darkGreetingGradient = LinearGradient(
    colors: [Color(0xFF7F90FF), Color(0xFF6B7CFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// EN: Carousel card overlay gradient — transparent → 70% black
  /// KO: 캐러셀 카드 오버레이 그라디언트 — 투명 → 70% 검정
  static const LinearGradient carouselCardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xB3000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.4, 1.0],
  );

  // EN: Shimmer colors for loading placeholders (neutral)
  // KO: 로딩 플레이스홀더를 위한 쉬머 색상 (뉴트럴)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color darkShimmerBase = Color(0xFF1E1E1E);
  static const Color darkShimmerHighlight = Color(0xFF2C2C2C);
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

/// EN: Semantic color mappings for consistent UI/UX across the application.
/// Provides meaningful color assignments based on UI/UX Pro Max analysis,
/// ensuring clear visual hierarchy and intentional color usage.
///
/// KO: 애플리케이션 전반의 일관된 UI/UX를 위한 의미론적 색상 매핑.
/// UI/UX Pro Max 분석 기반의 의미 있는 색상 할당을 제공하며,
/// 명확한 시각적 계층 구조와 의도적인 색상 사용을 보장합니다.
class GBTSemanticColors {
  GBTSemanticColors._();

  // ========================================
  // EN: Badge & Status Indicators
  // KO: 배지 및 상태 표시기
  // ========================================

  /// EN: Verified badge color (green) — indicates authenticated/verified status
  /// KO: 인증 배지 색상 (그린) — 인증됨/확인됨 상태 표시
  static const Color badgeVerified = GBTColors.verified; // #10B981

  /// EN: Live badge color (red) — indicates live/active status
  /// KO: 라이브 배지 색상 (레드) — 라이브/활성 상태 표시
  static const Color badgeLive = GBTColors.live; // #EF4444

  /// EN: Info badge color (blue) — general informational badges
  /// KO: 정보 배지 색상 (블루) — 일반 정보 배지
  static const Color badgeInfo = GBTColors.accentBlue; // #3B82F6

  /// EN: Warning badge color (amber) — alerts and warnings
  /// KO: 경고 배지 색상 (엠버) — 경고 및 주의사항
  static const Color badgeWarning = GBTColors.warning; // #F59E0B

  // ========================================
  // EN: Metadata & Auxiliary Information
  // KO: 메타데이터 및 보조 정보
  // ========================================

  /// EN: Distance metadata color (teal) — location distance indicators
  /// KO: 거리 메타데이터 색상 (틸) — 위치 거리 표시기
  static const Color metadataDistance = GBTColors.accentTeal; // #14B8A6

  /// EN: Rating metadata color (amber) — star ratings and scores
  /// KO: 평점 메타데이터 색상 (엠버) — 별점 및 점수
  static const Color metadataRating = GBTColors.rating; // #F59E0B

  // ========================================
  // EN: Interactive Elements (Call-to-Action)
  // KO: 인터랙티브 요소 (콜 투 액션)
  // ========================================

  /// EN: Primary CTA color (periwinkle) — main action buttons
  /// KO: 주요 CTA 색상 (페리윙클) — 기본 액션 버튼
  static const Color ctaPrimary = GBTColors.primary; // #A6B1FF

  /// EN: Secondary CTA color (pink) — high-energy emphasis actions
  /// Provides strong visual weight for important secondary actions
  /// KO: 보조 CTA 색상 (핑크) — 고에너지 강조 액션
  /// 중요한 보조 액션에 강한 시각적 무게 제공
  static const Color ctaSecondary = GBTColors.secondary; // #EC4899

  /// EN: Emphasis CTA color (amber) — general emphasis and highlights
  /// KO: 일반 강조 CTA 색상 (엠버) — 일반 강조 및 하이라이트
  static const Color ctaEmphasis = GBTColors.accent; // #F59E0B

  // ========================================
  // EN: Dark Mode Overrides (Enhanced Visibility)
  // KO: 다크 모드 재정의 (가시성 향상)
  // ========================================

  /// EN: Dark mode distance color (bright teal) — improved contrast on dark surfaces
  /// KO: 다크 모드 거리 색상 (밝은 틸) — 다크 표면에서 개선된 대비
  static const Color darkMetadataDistance = Color(0xFF2DD4BF);

  /// EN: Dark mode info color (bright blue) — improved contrast on dark surfaces
  /// KO: 다크 모드 정보 색상 (밝은 블루) — 다크 표면에서 개선된 대비
  static const Color darkAccentBlue = Color(0xFF60A5FA);

  /// EN: Dark mode verified color (bright green) — improved contrast on dark surfaces
  /// KO: 다크 모드 인증 색상 (밝은 그린) — 다크 표면에서 개선된 대비
  static const Color darkVerified = Color(0xFF34D399);

  // ========================================
  // EN: Helper Methods for Context-Aware Colors
  // KO: 컨텍스트 인식 색상을 위한 헬퍼 메서드
  // ========================================

  /// EN: Get distance color based on theme brightness
  /// KO: 테마 밝기에 따른 거리 색상 반환
  static Color getDistanceColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkMetadataDistance
        : metadataDistance;
  }

  /// EN: Get info badge color based on theme brightness
  /// KO: 테마 밝기에 따른 정보 배지 색상 반환
  static Color getInfoColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkAccentBlue : badgeInfo;
  }

  /// EN: Get verified badge color based on theme brightness
  /// KO: 테마 밝기에 따른 인증 배지 색상 반환
  static Color getVerifiedColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkVerified : badgeVerified;
  }
}
