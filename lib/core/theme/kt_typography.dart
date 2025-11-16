import 'package:flutter/material.dart';
import 'kt_colors.dart';

/// EN: KT UXD design system typography for Flutter applications
/// KO: Flutter 애플리케이션용 KT UXD 디자인 시스템 타이포그래피
class KTTypography {
  // EN: Font family based on KT UXD analysis - Pretendard
  // KO: KT UXD 분석을 기반으로 한 폰트 패밀리 - Pretendard
  static const String fontFamily = 'Pretendard';
  
  // EN: Fallback font families for different platforms
  // KO: 다양한 플랫폼을 위한 대체 폰트 패밀리
  static const List<String> fontFamilyFallback = [
    'Pretendard',
    '-apple-system',
    'BlinkMacSystemFont',
    'SF Pro Display',
    'Apple SD Gothic Neo',
    'Noto Sans CJK KR',
    'sans-serif',
  ];
  
  // EN: Display text styles for large headings and hero content
  // KO: 대형 제목과 히어로 콘텐츠를 위한 디스플레이 텍스트 스타일
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w700, // Bold
    fontSize: 44,
    letterSpacing: -1.2,
    height: 1.2,
    color: KTColors.primaryText,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w700, // Bold
    fontSize: 36,
    letterSpacing: -1.0,
    height: 1.2,
    color: KTColors.primaryText,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 32,
    letterSpacing: -0.8,
    height: 1.3,
    color: KTColors.primaryText,
  );
  
  // EN: Headline text styles for section headers
  // KO: 섹션 헤더를 위한 헤드라인 텍스트 스타일
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w700, // Bold
    fontSize: 28,
    letterSpacing: -0.6,
    height: 1.3,
    color: KTColors.primaryText,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 22,
    letterSpacing: -0.4,
    height: 1.4,
    color: KTColors.primaryText,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 20,
    letterSpacing: -0.2,
    height: 1.4,
    color: KTColors.primaryText,
  );
  
  // EN: Title text styles for cards and component headers
  // KO: 카드와 컴포넌트 헤더를 위한 타이틀 텍스트 스타일
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 20,
    height: 1.4,
    color: KTColors.primaryText,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 16,
    height: 1.5,
    color: KTColors.primaryText,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 1.4,
    color: KTColors.primaryText,
  );
  
  // EN: Body text styles for content and descriptions
  // KO: 콘텐츠와 설명을 위한 본문 텍스트 스타일
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500, // Medium (based on KT UXD analysis)
    fontSize: 18,
    height: 1.5, // 27px line height from analysis
    color: KTColors.primaryText,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    height: 1.5,
    color: KTColors.primaryText,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14,
    height: 1.4,
    color: KTColors.secondaryText,
  );
  
  // EN: Label text styles for buttons, forms, and UI elements
  // KO: 버튼, 폼, UI 요소를 위한 라벨 텍스트 스타일
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 14,
    letterSpacing: 0.3,
    height: 1.4,
    color: KTColors.primaryText,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 12,
    letterSpacing: 0.2,
    height: 1.3,
    color: KTColors.primaryText,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 11,
    letterSpacing: 0.2,
    height: 1.3,
    color: KTColors.secondaryText,
  );
  
  // EN: Caption text style for additional information
  // KO: 추가 정보를 위한 캡션 텍스트 스타일
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    height: 1.3,
    color: KTColors.secondaryText,
  );
  
  // EN: Overline text style for categories and metadata
  // KO: 카테고리와 메타데이터를 위한 오버라인 텍스트 스타일
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 10,
    letterSpacing: 1.5,
    height: 1.6,
    color: KTColors.secondaryText,
  );
  
  // EN: Specialized text styles for specific components
  // KO: 특정 컴포넌트를 위한 전문 텍스트 스타일
  
  /// EN: Button text style with proper weight and letter spacing
  /// KO: 적절한 굵기와 글자 간격을 가진 버튼 텍스트 스타일
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 14,
    letterSpacing: 0.3,
    height: 1.2,
  );
  
  /// EN: Input field text style for forms
  /// KO: 폼을 위한 입력 필드 텍스트 스타일
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    height: 1.5,
    color: KTColors.primaryText,
  );
  
  /// EN: Placeholder text style for input fields
  /// KO: 입력 필드를 위한 플레이스홀더 텍스트 스타일
  static const TextStyle placeholder = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    height: 1.5,
    color: KTColors.secondaryText,
  );
  
  /// EN: Navigation text style for menu items
  /// KO: 메뉴 항목을 위한 네비게이션 텍스트 스타일
  static const TextStyle navigation = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 1.4,
    color: KTColors.primaryText,
  );
  
  // EN: Utility methods for dynamic text styling
  // KO: 동적 텍스트 스타일링을 위한 유틸리티 메서드
  
  /// EN: Create text style with custom color while maintaining other properties
  /// KO: 다른 속성을 유지하면서 사용자 지정 색상으로 텍스트 스타일 생성
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// EN: Create text style with custom font weight
  /// KO: 사용자 지정 폰트 굵기로 텍스트 스타일 생성
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// EN: Create text style with custom font size
  /// KO: 사용자 지정 폰트 크기로 텍스트 스타일 생성
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  /// EN: Create text style optimized for specific locales
  /// KO: 특정 로케일에 최적화된 텍스트 스타일 생성
  static TextStyle forLocale(TextStyle style, Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        // EN: Optimized for Korean text with better line height
        // KO: 더 나은 행간으로 한글 텍스트에 최적화
        return style.copyWith(
          height: (style.height ?? 1.5) * 1.1,
          fontFamily: fontFamily,
        );
      case 'en':
        // EN: Optimized for English text
        // KO: 영문 텍스트에 최적화
        return style.copyWith(
          height: style.height ?? 1.4,
          fontFamily: fontFamily,
        );
      case 'ja':
        // EN: Optimized for Japanese text
        // KO: 일본어 텍스트에 최적화
        return style.copyWith(
          height: (style.height ?? 1.5) * 1.2,
          fontFamily: 'NotoSansJP',
          fontFamilyFallback: [fontFamily, ...fontFamilyFallback],
        );
      default:
        return style;
    }
  }
  
  // EN: Text theme for Material Design integration
  // KO: Material Design 통합을 위한 텍스트 테마
  static TextTheme get textTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}