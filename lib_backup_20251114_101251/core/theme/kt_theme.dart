import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kt_colors.dart';
import 'kt_typography.dart';
import 'kt_spacing.dart';

/// EN: Complete KT UXD theme implementation for Flutter applications
/// KO: Flutter 애플리케이션용 완전한 KT UXD 테마 구현
class KTTheme {
  // EN: Light theme based on KT UXD design system
  // KO: KT UXD 디자인 시스템을 기반으로 한 라이트 테마
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = _lightColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: KTTypography.textTheme,
      fontFamily: KTTypography.fontFamily,
      
      // EN: App bar theme following KT UXD style
      // KO: KT UXD 스타일을 따르는 앱 바 테마
      appBarTheme: _buildAppBarTheme(colorScheme),
      
      // EN: Button themes for consistent styling
      // KO: 일관된 스타일링을 위한 버튼 테마
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      filledButtonTheme: _buildFilledButtonTheme(colorScheme),
      
      // EN: Input decoration theme for forms
      // KO: 폼을 위한 입력 장식 테마
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      
      // EN: Card theme for containers
      // KO: 컨테이너를 위한 카드 테마
      cardTheme: _buildCardTheme(colorScheme),
      
      // EN: Navigation theme
      // KO: 네비게이션 테마
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme),
      
      // EN: Dialog and modal theme
      // KO: 다이얼로그와 모달 테마
      dialogTheme: _buildDialogTheme(colorScheme),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme),
      
      // EN: Other component themes
      // KO: 기타 컴포넌트 테마
      dividerTheme: _buildDividerTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      switchTheme: _buildSwitchTheme(colorScheme),
      checkboxTheme: _buildCheckboxTheme(colorScheme),
      radioTheme: _buildRadioTheme(colorScheme),
      sliderTheme: _buildSliderTheme(colorScheme),
      
      // EN: Scaffold and background
      // KO: 스캐폴드와 배경
      scaffoldBackgroundColor: KTColors.background,
      
      // EN: Visual density for touch interactions
      // KO: 터치 상호작용을 위한 시각적 밀도
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // EN: Material state properties
      // KO: Material 상태 속성
      splashFactory: InkRipple.splashFactory,
    );
  }
  
  // EN: Dark theme for future implementation
  // KO: 향후 구현을 위한 다크 테마
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = _darkColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _darkTextTheme,
      fontFamily: KTTypography.fontFamily,
      scaffoldBackgroundColor: KTColors.darkBackground,
      // EN: Additional dark theme configurations will be added here
      // KO: 추가 다크 테마 구성이 여기에 추가될 예정
    );
  }
  
  // EN: Light color scheme based on KT UXD colors
  // KO: KT UXD 색상을 기반으로 한 라이트 색상 스키마
  static ColorScheme get _lightColorScheme {
    return const ColorScheme.light(
      brightness: Brightness.light,
      primary: KTColors.primaryText,
      onPrimary: KTColors.background,
      primaryContainer: KTColors.surfaceAlternate,
      onPrimaryContainer: KTColors.primaryText,
      secondary: KTColors.accentSecondary,
      onSecondary: KTColors.background,
      secondaryContainer: KTColors.surfaceAlternate,
      onSecondaryContainer: KTColors.primaryText,
      tertiary: KTColors.statusNeutral,
      onTertiary: KTColors.background,
      tertiaryContainer: KTColors.surfaceAlternate,
      onTertiaryContainer: KTColors.primaryText,
      error: KTColors.error,
      onError: KTColors.background,
      errorContainer: Color(0xFFFFEDEA),
      onErrorContainer: KTColors.error,
      background: KTColors.background,
      onBackground: KTColors.primaryText,
      surface: KTColors.surface,
      onSurface: KTColors.primaryText,
      surfaceVariant: KTColors.surfaceAlternate,
      onSurfaceVariant: KTColors.secondaryText,
      outline: KTColors.borderColor,
      outlineVariant: KTColors.borderColor,
      shadow: KTColors.cardShadow,
      scrim: KTColors.overlay,
      inverseSurface: KTColors.primaryText,
      onInverseSurface: KTColors.background,
      inversePrimary: KTColors.background,
    );
  }
  
  // EN: Dark color scheme for future dark mode implementation
  // KO: 향후 다크 모드 구현을 위한 다크 색상 스키마
  static ColorScheme get _darkColorScheme {
    return const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: KTColors.darkPrimaryText,
      onPrimary: KTColors.darkBackground,
      background: KTColors.darkBackground,
      onBackground: KTColors.darkPrimaryText,
      surface: KTColors.darkSurface,
      onSurface: KTColors.darkPrimaryText,
      outline: KTColors.darkBorderColor,
    );
  }
  
  // EN: Dark text theme
  // KO: 다크 텍스트 테마
  static TextTheme get _darkTextTheme {
    return KTTypography.textTheme.copyWith(
      displayLarge: KTTypography.displayLarge.copyWith(color: KTColors.darkPrimaryText),
      displayMedium: KTTypography.displayMedium.copyWith(color: KTColors.darkPrimaryText),
      displaySmall: KTTypography.displaySmall.copyWith(color: KTColors.darkPrimaryText),
      headlineLarge: KTTypography.headlineLarge.copyWith(color: KTColors.darkPrimaryText),
      headlineMedium: KTTypography.headlineMedium.copyWith(color: KTColors.darkPrimaryText),
      headlineSmall: KTTypography.headlineSmall.copyWith(color: KTColors.darkPrimaryText),
      titleLarge: KTTypography.titleLarge.copyWith(color: KTColors.darkPrimaryText),
      titleMedium: KTTypography.titleMedium.copyWith(color: KTColors.darkPrimaryText),
      titleSmall: KTTypography.titleSmall.copyWith(color: KTColors.darkPrimaryText),
      bodyLarge: KTTypography.bodyLarge.copyWith(color: KTColors.darkPrimaryText),
      bodyMedium: KTTypography.bodyMedium.copyWith(color: KTColors.darkPrimaryText),
      bodySmall: KTTypography.bodySmall.copyWith(color: KTColors.darkSecondaryText),
      labelLarge: KTTypography.labelLarge.copyWith(color: KTColors.darkPrimaryText),
      labelMedium: KTTypography.labelMedium.copyWith(color: KTColors.darkPrimaryText),
      labelSmall: KTTypography.labelSmall.copyWith(color: KTColors.darkSecondaryText),
    );
  }
  
  // EN: App bar theme configuration
  // KO: 앱 바 테마 구성
  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: KTSpacing.elevationSubtle,
      backgroundColor: KTColors.navBackground,
      foregroundColor: KTColors.primaryText,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: KTTypography.titleLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: KTColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  // EN: Elevated button theme
  // KO: 엘리베이티드 버튼 테마
  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KTColors.buttonPrimary,
        foregroundColor: KTColors.background,
        elevation: KTSpacing.elevationLow,
        shadowColor: KTColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KTSpacing.lg,
          vertical: KTSpacing.md,
        ),
        minimumSize: const Size(120, KTSpacing.touchTarget),
        maximumSize: const Size(double.infinity, KTSpacing.touchTarget),
        textStyle: KTTypography.button,
      ),
    );
  }
  
  // EN: Text button theme
  // KO: 텍스트 버튼 테마
  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: KTColors.primaryText,
        backgroundColor: Colors.transparent,
        elevation: KTSpacing.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KTSpacing.md,
          vertical: KTSpacing.sm,
        ),
        minimumSize: const Size(80, KTSpacing.touchTarget - 8),
        textStyle: KTTypography.button,
      ),
    );
  }
  
  // EN: Outlined button theme
  // KO: 아웃라인 버튼 테마
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KTColors.primaryText,
        backgroundColor: KTColors.background,
        elevation: KTSpacing.elevationNone,
        side: const BorderSide(color: KTColors.borderColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KTSpacing.lg,
          vertical: KTSpacing.md,
        ),
        minimumSize: const Size(120, KTSpacing.touchTarget),
        textStyle: KTTypography.button,
      ),
    );
  }
  
  // EN: Filled button theme
  // KO: 채움 버튼 테마
  static FilledButtonThemeData _buildFilledButtonTheme(ColorScheme colorScheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: KTColors.primaryText,
        foregroundColor: KTColors.background,
        elevation: KTSpacing.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KTSpacing.lg,
          vertical: KTSpacing.md,
        ),
        minimumSize: const Size(120, KTSpacing.touchTarget),
        textStyle: KTTypography.button,
      ),
    );
  }
  
  // EN: Input decoration theme for consistent form styling
  // KO: 일관된 폼 스타일링을 위한 입력 장식 테마
  static InputDecorationTheme _buildInputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: KTColors.inputFill,
      contentPadding: const EdgeInsets.all(KTSpacing.md),
      
      // EN: Border styles for different states
      // KO: 다양한 상태를 위한 경계선 스타일
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        borderSide: const BorderSide(color: KTColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        borderSide: const BorderSide(color: KTColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        borderSide: const BorderSide(color: KTColors.inputBorderFocused, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        borderSide: const BorderSide(color: KTColors.inputBorderError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        borderSide: const BorderSide(color: KTColors.inputBorderError, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
        borderSide: BorderSide(color: KTColors.borderColorLight),
      ),
      
      // EN: Text styles for input fields
      // KO: 입력 필드를 위한 텍스트 스타일
      labelStyle: KTTypography.labelMedium.copyWith(color: KTColors.secondaryText),
      floatingLabelStyle: KTTypography.labelMedium.copyWith(color: KTColors.primaryText),
      hintStyle: KTTypography.placeholder,
      errorStyle: KTTypography.labelSmall.copyWith(color: KTColors.error),
      helperStyle: KTTypography.labelSmall.copyWith(color: KTColors.secondaryText),
      
      // EN: Icon styling
      // KO: 아이콘 스타일링
      prefixIconColor: KTColors.secondaryText,
      suffixIconColor: KTColors.secondaryText,
    );
  }
  
  // EN: Card theme for containers and surfaces
  // KO: 컨테이너와 표면을 위한 카드 테마
  static CardTheme _buildCardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: KTSpacing.elevationSubtle,
      color: KTColors.cardBackground,
      shadowColor: KTColors.cardShadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusMedium),
        side: const BorderSide(color: KTColors.cardBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    );
  }
  
  // EN: Bottom navigation bar theme
  // KO: 하단 네비게이션 바 테마
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: KTColors.navBackground,
      selectedItemColor: KTColors.navIconActive,
      unselectedItemColor: KTColors.navIconInactive,
      selectedLabelStyle: KTTypography.navigation.copyWith(
        fontWeight: FontWeight.w600,
        color: KTColors.navIconActive,
      ),
      unselectedLabelStyle: KTTypography.navigation.copyWith(
        color: KTColors.navIconInactive,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: KTSpacing.elevationLow,
    );
  }
  
  // EN: Navigation bar theme (Material 3)
  // KO: 네비게이션 바 테마 (Material 3)
  static NavigationBarThemeData _buildNavigationBarTheme(ColorScheme colorScheme) {
    return NavigationBarThemeData(
      backgroundColor: KTColors.navBackground,
      elevation: KTSpacing.elevationLow,
      height: 80,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return KTTypography.navigation.copyWith(
            fontWeight: FontWeight.w600,
            color: KTColors.navIconActive,
          );
        }
        return KTTypography.navigation.copyWith(
          color: KTColors.navIconInactive,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: KTColors.navIconActive);
        }
        return const IconThemeData(color: KTColors.navIconInactive);
      }),
    );
  }
  
  // EN: Dialog theme for modals and alerts
  // KO: 모달과 알림을 위한 다이얼로그 테마
  static DialogTheme _buildDialogTheme(ColorScheme colorScheme) {
    return DialogTheme(
      backgroundColor: KTColors.background,
      elevation: KTSpacing.elevationHigh,
      shadowColor: KTColors.cardShadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusLarge),
      ),
      titleTextStyle: KTTypography.headlineSmall.copyWith(
        color: KTColors.primaryText,
      ),
      contentTextStyle: KTTypography.bodyMedium.copyWith(
        color: KTColors.primaryText,
      ),
    );
  }
  
  // EN: Bottom sheet theme
  // KO: 하단 시트 테마
  static BottomSheetThemeData _buildBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: KTColors.background,
      elevation: KTSpacing.elevationMedium,
      modalElevation: KTSpacing.elevationHigh,
      shadowColor: KTColors.cardShadow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KTSpacing.borderRadiusLarge),
        ),
      ),
    );
  }
  
  // EN: Additional component themes
  // KO: 추가 컴포넌트 테마
  
  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme) {
    return const DividerThemeData(
      color: KTColors.borderColor,
      thickness: 1,
      space: 1,
    );
  }
  
  static ChipThemeData _buildChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: KTColors.surfaceAlternate,
      deleteIconColor: KTColors.secondaryText,
      disabledColor: KTColors.borderColor,
      selectedColor: KTColors.primaryText,
      secondarySelectedColor: KTColors.accentSecondary,
      padding: const EdgeInsets.symmetric(
        horizontal: KTSpacing.sm,
        vertical: KTSpacing.xs,
      ),
      labelStyle: KTTypography.labelMedium,
      secondaryLabelStyle: KTTypography.labelMedium.copyWith(
        color: KTColors.background,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KTSpacing.borderRadiusSmall),
      ),
    );
  }
  
  static SwitchThemeData _buildSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return KTColors.background;
        }
        return KTColors.secondaryText;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return KTColors.primaryText;
        }
        return KTColors.borderColor;
      }),
    );
  }
  
  static CheckboxThemeData _buildCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return KTColors.primaryText;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(KTColors.background),
      side: const BorderSide(color: KTColors.borderColor, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  static RadioThemeData _buildRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return KTColors.primaryText;
        }
        return KTColors.borderColor;
      }),
    );
  }
  
  static SliderThemeData _buildSliderTheme(ColorScheme colorScheme) {
    return SliderThemeData(
      activeTrackColor: KTColors.primaryText,
      inactiveTrackColor: KTColors.borderColor,
      thumbColor: KTColors.background,
      overlayColor: KTColors.primaryTextLight,
      valueIndicatorColor: KTColors.primaryText,
      valueIndicatorTextStyle: KTTypography.labelSmall.copyWith(
        color: KTColors.background,
      ),
    );
  }
}