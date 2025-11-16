import 'package:flutter/material.dart';

/// EN: KT UXD design system color palette for Flutter applications
/// KO: Flutter 애플리케이션용 KT UXD 디자인 시스템 색상 팔레트
class KTColors {
  // EN: Primary text and UI colors based on KT UXD analysis
  // KO: KT UXD 분석을 기반으로 한 기본 텍스트 및 UI 색상
  static const Color primaryText = Color(0xFF1A1A1A);      // 진한 회색 (메인 텍스트)
  static const Color secondaryText = Color(0xFF404040);    // 중간 회색 (보조 텍스트)
  static const Color borderColor = Color(0xFFEBEBEB);      // 연한 회색 (경계선)
  static const Color background = Color(0xFFFFFFFF);       // 흰색 (배경)
  static const Color surfaceAlternate = Color(0xFFF5F5F5); // 매우 연한 회색 (대체 표면)
  
  // EN: Status colors for different UI states
  // KO: 다양한 UI 상태를 위한 상태 색상
  static const Color statusNeutral = Color(0xFF0FABBE);    // 시안 (중성)
  static const Color statusPositive = Color(0xFF6941FF);   // 보라 (긍정)
  static const Color statusNegative = Color(0xFF0099E0);   // 파랑 (부정)
  
  // EN: Accent colors for brand expression
  // KO: 브랜드 표현을 위한 액센트 색상
  static const Color accent = Color(0xFF1A1A1A);
  static const Color accentSecondary = Color(0xFF0FABBE);
  
  // EN: Semantic colors for user feedback
  // KO: 사용자 피드백을 위한 시맨틱 색상
  static const Color success = Color(0xFF38D39F);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFFF5D5D);
  static const Color info = Color(0xFF0099E0);
  
  // EN: Interactive element colors
  // KO: 인터랙티브 요소 색상
  static const Color buttonPrimary = Color(0xFF1A1A1A);
  static const Color buttonSecondary = Color(0xFFFFFFFF);
  static const Color buttonTertiary = Colors.transparent;
  
  // EN: Surface colors for depth and layering
  // KO: 깊이와 레이어링을 위한 표면 색상
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAFAFA);
  static const Color overlay = Color(0x80000000);
  
  // EN: Input field specific colors
  // KO: 입력 필드 전용 색상
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFEBEBEB);
  static const Color inputBorderFocused = Color(0xFF1A1A1A);
  static const Color inputBorderError = Color(0xFFFF5D5D);
  
  // EN: Card and container colors
  // KO: 카드 및 컨테이너 색상
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEBEBEB);
  static const Color cardShadow = Color(0x0F000000);
  
  // EN: Navigation specific colors
  // KO: 네비게이션 전용 색상
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navIconActive = Color(0xFF1A1A1A);
  static const Color navIconInactive = Color(0xFF404040);
  static const Color navBorder = Color(0xFFEBEBEB);
  
  // EN: Gradient colors for backgrounds and hero sections
  // KO: 배경과 히어로 섹션을 위한 그라데이션 색상
  static const List<Color> backgroundGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFFAFAFA),
    Color(0xFFF5F5F5),
  ];
  
  static const List<Color> heroGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF404040),
    Color(0xFF0FABBE),
  ];
  
  // EN: Dark mode colors (for future implementation)
  // KO: 다크모드 색상 (향후 구현용)
  static const Color darkPrimaryText = Color(0xFFF7FAFF);
  static const Color darkSecondaryText = Color(0xFF9BA4C3);
  static const Color darkBackground = Color(0xFF0E121B);
  static const Color darkSurface = Color(0xFF161C2A);
  static const Color darkBorderColor = Color(0xFF273952);
  
  // EN: Opacity variants for layering
  // KO: 레이어링을 위한 투명도 변형
  static Color get primaryTextLight => primaryText.withOpacity(0.7);
  static Color get secondaryTextLight => secondaryText.withOpacity(0.6);
  static Color get borderColorLight => borderColor.withOpacity(0.5);
  static Color get overlayLight => overlay.withOpacity(0.3);
  
  // EN: Utility method to get color with custom opacity
  // KO: 사용자 지정 투명도로 색상을 가져오는 유틸리티 메서드
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // EN: Method to validate color contrast for accessibility
  // KO: 접근성을 위한 색상 대비 검증 메서드
  static bool hasValidContrast(Color foreground, Color background) {
    const double minimumContrastRatio = 4.5; // WCAG AA standard
    final double luminance1 = foreground.computeLuminance();
    final double luminance2 = background.computeLuminance();
    final double brightest = luminance1 > luminance2 ? luminance1 : luminance2;
    final double darkest = luminance1 < luminance2 ? luminance1 : luminance2;
    final double contrastRatio = (brightest + 0.05) / (darkest + 0.05);
    return contrastRatio >= minimumContrastRatio;
  }
}