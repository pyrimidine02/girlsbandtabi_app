/// EN: GBT typography system based on KT UXD design system
/// KO: KT UXD 디자인 시스템 기반 GBT 타이포그래피 시스템
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// EN: Typography constants and styles for the application
/// KO: 앱의 타이포그래피 상수 및 스타일
class GBTTypography {
  GBTTypography._();

  // ========================================
  // EN: Font Family
  // KO: 폰트 패밀리
  // ========================================
  static const String primaryFontFamily = 'Pretendard';
  static const String secondaryFontFamily = 'NunitoSans';

  /// EN: Get base text style with Pretendard or fallback to system font
  /// KO: Pretendard 또는 시스템 폰트로 폴백하는 기본 텍스트 스타일 반환
  static TextStyle get _baseStyle => GoogleFonts.notoSansKr();

  // ========================================
  // EN: Display Styles (Large titles)
  // KO: 디스플레이 스타일 (큰 제목)
  // ========================================
  static TextStyle get displayLarge => _baseStyle.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle get displayMedium => _baseStyle.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle get displaySmall => _baseStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
  );

  // ========================================
  // EN: Headline Styles (Section headers)
  // KO: 헤드라인 스타일 (섹션 헤더)
  // ========================================
  static TextStyle get headlineLarge => _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get headlineMedium => _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle get headlineSmall => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ========================================
  // EN: Title Styles (Card titles, list items)
  // KO: 타이틀 스타일 (카드 제목, 리스트 아이템)
  // ========================================
  static TextStyle get titleLarge => _baseStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle get titleMedium => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get titleSmall => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ========================================
  // EN: Body Styles (Main content text)
  // KO: 본문 스타일 (메인 콘텐츠 텍스트)
  // ========================================
  static TextStyle get bodyLarge => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle get bodySmall => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ========================================
  // EN: Label Styles (Buttons, chips, tags)
  // KO: 라벨 스타일 (버튼, 칩, 태그)
  // ========================================
  static TextStyle get labelLarge => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ========================================
  // EN: Additional Utility Styles
  // KO: 추가 유틸리티 스타일
  // ========================================
  static TextStyle get caption => _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get overline => _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // ========================================
  // EN: Special Purpose Styles
  // KO: 특수 목적 스타일
  // ========================================
  static TextStyle get button =>
      labelLarge.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get tabLabel =>
      labelMedium.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get badge => _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );

  static TextStyle get price =>
      titleMedium.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get distance =>
      bodySmall.copyWith(fontWeight: FontWeight.w500);
}

/// EN: Extension for applying color to text styles
/// KO: 텍스트 스타일에 색상을 적용하는 확장
extension GBTTextStyleExtension on TextStyle {
  /// EN: Apply color to text style
  /// KO: 텍스트 스타일에 색상 적용
  TextStyle withColor(Color color) => copyWith(color: color);

  /// EN: Apply semi-bold weight
  /// KO: 세미볼드 웨이트 적용
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// EN: Apply bold weight
  /// KO: 볼드 웨이트 적용
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// EN: Apply medium weight
  /// KO: 미디엄 웨이트 적용
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// EN: Apply regular weight
  /// KO: 레귤러 웨이트 적용
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
}

/// EN: Extension for localization support
/// KO: 다국어 지원을 위한 확장
extension GBTTypographyLocalization on TextStyle {
  /// EN: Adjust typography for different locales
  /// KO: 로케일별 타이포그래피 조정
  TextStyle forLocale(Locale locale) {
    return switch (locale.languageCode) {
      'ko' => copyWith(height: height != null ? height! * 1.1 : 1.5),
      'ja' => copyWith(height: height != null ? height! * 1.2 : 1.6),
      _ => this,
    };
  }
}
