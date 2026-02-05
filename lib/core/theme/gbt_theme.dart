/// EN: GBT theme configuration integrating colors, typography, and spacing
/// KO: 색상, 타이포그래피, 간격을 통합하는 GBT 테마 구성
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'gbt_colors.dart';
import 'gbt_spacing.dart';
import 'gbt_typography.dart';

/// EN: Main theme class for the application
/// KO: 앱의 메인 테마 클래스
class GBTTheme {
  GBTTheme._();

  // ========================================
  // EN: Light Theme
  // KO: 라이트 테마
  // ========================================
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _lightAppBarTheme,
      bottomNavigationBarTheme: _lightBottomNavTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      dividerTheme: _dividerTheme,
      chipTheme: _chipTheme,
      floatingActionButtonTheme: _fabTheme,
      bottomSheetTheme: _bottomSheetTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
      tabBarTheme: _tabBarTheme,
      scaffoldBackgroundColor: GBTColors.background,
      splashColor: GBTColors.ripple,
      highlightColor: Colors.transparent,
    );
  }

  // ========================================
  // EN: Dark Theme
  // KO: 다크 테마
  // ========================================
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: _darkTextTheme,
      appBarTheme: _darkAppBarTheme,
      bottomNavigationBarTheme: _darkBottomNavTheme,
      cardTheme: _darkCardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _darkInputDecorationTheme,
      dividerTheme: _darkDividerTheme,
      chipTheme: _darkChipTheme,
      floatingActionButtonTheme: _fabTheme,
      bottomSheetTheme: _darkBottomSheetTheme,
      dialogTheme: _darkDialogTheme,
      snackBarTheme: _snackBarTheme,
      tabBarTheme: _darkTabBarTheme,
      scaffoldBackgroundColor: GBTColors.darkBackground,
      splashColor: GBTColors.ripple,
      highlightColor: Colors.transparent,
    );
  }

  // ========================================
  // EN: Color Schemes
  // KO: 색상 스키마
  // ========================================
  static ColorScheme get _lightColorScheme => ColorScheme(
    brightness: Brightness.light,
    primary: GBTColors.primary,
    onPrimary: GBTColors.textInverse,
    primaryContainer: GBTColors.surfaceVariant,
    onPrimaryContainer: GBTColors.textPrimary,
    secondary: GBTColors.secondary,
    onSecondary: GBTColors.textInverse,
    secondaryContainer: GBTColors.surfaceVariant,
    onSecondaryContainer: GBTColors.textPrimary,
    tertiary: GBTColors.accent,
    onTertiary: GBTColors.textInverse,
    error: GBTColors.error,
    onError: GBTColors.textInverse,
    surface: GBTColors.surface,
    onSurface: GBTColors.textPrimary,
    surfaceContainerHighest: GBTColors.surfaceVariant,
    onSurfaceVariant: GBTColors.textSecondary,
    outline: GBTColors.border,
    outlineVariant: GBTColors.divider,
    shadow: Colors.black,
    scrim: GBTColors.scrim,
  );

  static ColorScheme get _darkColorScheme => ColorScheme(
    brightness: Brightness.dark,
    // EN: Use lighter accent for primary in dark mode for visibility
    // KO: 다크 모드에서 가시성을 위해 밝은 강조색을 primary로 사용
    primary: GBTColors.darkTextPrimary,
    onPrimary: GBTColors.darkBackground,
    primaryContainer: GBTColors.darkSurfaceElevated,
    onPrimaryContainer: GBTColors.darkTextPrimary,
    secondary: GBTColors.secondary,
    onSecondary: GBTColors.darkTextPrimary,
    secondaryContainer: GBTColors.darkSurfaceVariant,
    onSecondaryContainer: GBTColors.darkTextPrimary,
    tertiary: GBTColors.accent,
    onTertiary: GBTColors.darkTextPrimary,
    error: GBTColors.error,
    onError: GBTColors.darkTextPrimary,
    surface: GBTColors.darkSurface,
    onSurface: GBTColors.darkTextPrimary,
    surfaceContainerHighest: GBTColors.darkSurfaceVariant,
    onSurfaceVariant: GBTColors.darkTextSecondary,
    outline: GBTColors.darkBorder,
    outlineVariant: GBTColors.darkBorderSubtle,
    shadow: Colors.black,
    scrim: GBTColors.scrim,
  );

  // ========================================
  // EN: Text Theme
  // KO: 텍스트 테마
  // ========================================
  static TextTheme get _textTheme => TextTheme(
    displayLarge: GBTTypography.displayLarge.copyWith(
      color: GBTColors.textPrimary,
    ),
    displayMedium: GBTTypography.displayMedium.copyWith(
      color: GBTColors.textPrimary,
    ),
    displaySmall: GBTTypography.displaySmall.copyWith(
      color: GBTColors.textPrimary,
    ),
    headlineLarge: GBTTypography.headlineLarge.copyWith(
      color: GBTColors.textPrimary,
    ),
    headlineMedium: GBTTypography.headlineMedium.copyWith(
      color: GBTColors.textPrimary,
    ),
    headlineSmall: GBTTypography.headlineSmall.copyWith(
      color: GBTColors.textPrimary,
    ),
    titleLarge: GBTTypography.titleLarge.copyWith(color: GBTColors.textPrimary),
    titleMedium: GBTTypography.titleMedium.copyWith(
      color: GBTColors.textPrimary,
    ),
    titleSmall: GBTTypography.titleSmall.copyWith(color: GBTColors.textPrimary),
    bodyLarge: GBTTypography.bodyLarge.copyWith(color: GBTColors.textPrimary),
    bodyMedium: GBTTypography.bodyMedium.copyWith(color: GBTColors.textPrimary),
    bodySmall: GBTTypography.bodySmall.copyWith(color: GBTColors.textSecondary),
    labelLarge: GBTTypography.labelLarge.copyWith(color: GBTColors.textPrimary),
    labelMedium: GBTTypography.labelMedium.copyWith(
      color: GBTColors.textSecondary,
    ),
    labelSmall: GBTTypography.labelSmall.copyWith(
      color: GBTColors.textTertiary,
    ),
  );

  static TextTheme get _darkTextTheme => TextTheme(
    displayLarge: GBTTypography.displayLarge.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    displayMedium: GBTTypography.displayMedium.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    displaySmall: GBTTypography.displaySmall.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    headlineLarge: GBTTypography.headlineLarge.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    headlineMedium: GBTTypography.headlineMedium.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    headlineSmall: GBTTypography.headlineSmall.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    titleLarge: GBTTypography.titleLarge.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    titleMedium: GBTTypography.titleMedium.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    titleSmall: GBTTypography.titleSmall.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    bodyLarge: GBTTypography.bodyLarge.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    bodyMedium: GBTTypography.bodyMedium.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    bodySmall: GBTTypography.bodySmall.copyWith(
      color: GBTColors.darkTextSecondary,
    ),
    labelLarge: GBTTypography.labelLarge.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    labelMedium: GBTTypography.labelMedium.copyWith(
      color: GBTColors.darkTextSecondary,
    ),
    labelSmall: GBTTypography.labelSmall.copyWith(
      color: GBTColors.darkTextTertiary,
    ),
  );

  // ========================================
  // EN: AppBar Theme
  // KO: 앱바 테마
  // ========================================
  static AppBarTheme get _lightAppBarTheme => AppBarTheme(
    backgroundColor: GBTColors.background,
    foregroundColor: GBTColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: GBTTypography.titleMedium.copyWith(
      color: GBTColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(
      color: GBTColors.textPrimary,
      size: GBTSpacing.iconMd,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
    backgroundColor: GBTColors.darkSurface,
    foregroundColor: GBTColors.darkTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: GBTTypography.titleMedium.copyWith(
      color: GBTColors.darkTextPrimary,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(
      color: GBTColors.darkTextPrimary,
      size: GBTSpacing.iconMd,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );

  // ========================================
  // EN: Bottom Navigation Theme
  // KO: 하단 네비게이션 테마
  // ========================================
  static BottomNavigationBarThemeData get _lightBottomNavTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: GBTColors.background,
        selectedItemColor: GBTColors.primary,
        unselectedItemColor: GBTColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GBTTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GBTTypography.labelSmall,
      );

  static BottomNavigationBarThemeData get _darkBottomNavTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: GBTColors.darkSurface,
        selectedItemColor: GBTColors.darkTextPrimary,
        unselectedItemColor: GBTColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GBTTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GBTTypography.labelSmall,
      );

  // ========================================
  // EN: Card Theme
  // KO: 카드 테마
  // ========================================
  static CardThemeData get _cardTheme => CardThemeData(
    color: GBTColors.surface,
    elevation: GBTSpacing.elevationSm,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
    ),
    margin: EdgeInsets.zero,
  );

  static CardThemeData get _darkCardTheme => CardThemeData(
    color: GBTColors.darkSurfaceVariant,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      side: BorderSide(
        color: GBTColors.darkBorderSubtle,
        width: 0.5,
      ),
    ),
    margin: EdgeInsets.zero,
  );

  // ========================================
  // EN: Button Themes
  // KO: 버튼 테마
  // ========================================
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GBTColors.primary,
          foregroundColor: GBTColors.textInverse,
          elevation: GBTSpacing.elevationSm,
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.lg,
            vertical: GBTSpacing.md,
          ),
          minimumSize: const Size(120, GBTSpacing.touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          ),
          textStyle: GBTTypography.button,
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GBTColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.lg,
            vertical: GBTSpacing.md,
          ),
          minimumSize: const Size(120, GBTSpacing.touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          ),
          side: const BorderSide(color: GBTColors.border),
          textStyle: GBTTypography.button,
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: GBTColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.md,
        vertical: GBTSpacing.sm,
      ),
      minimumSize: const Size(64, GBTSpacing.minTouchTarget),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      textStyle: GBTTypography.button,
    ),
  );

  // ========================================
  // EN: Input Decoration Theme
  // KO: 입력 데코레이션 테마
  // ========================================
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: GBTColors.surfaceVariant,
    contentPadding: const EdgeInsets.all(GBTSpacing.md),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      borderSide: const BorderSide(color: GBTColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      borderSide: const BorderSide(color: GBTColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      borderSide: const BorderSide(color: GBTColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      borderSide: const BorderSide(color: GBTColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      borderSide: const BorderSide(color: GBTColors.error, width: 2),
    ),
    hintStyle: GBTTypography.bodyMedium.copyWith(color: GBTColors.textTertiary),
    labelStyle: GBTTypography.bodyMedium.copyWith(
      color: GBTColors.textSecondary,
    ),
    errorStyle: GBTTypography.bodySmall.copyWith(color: GBTColors.error),
  );

  static InputDecorationTheme get _darkInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: GBTColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.all(GBTSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          borderSide: const BorderSide(color: GBTColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          borderSide: const BorderSide(color: GBTColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          borderSide: const BorderSide(color: GBTColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          borderSide: const BorderSide(color: GBTColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          borderSide: const BorderSide(color: GBTColors.error, width: 2),
        ),
        hintStyle: GBTTypography.bodyMedium.copyWith(
          color: GBTColors.darkTextTertiary,
        ),
        labelStyle: GBTTypography.bodyMedium.copyWith(
          color: GBTColors.darkTextSecondary,
        ),
        errorStyle: GBTTypography.bodySmall.copyWith(color: GBTColors.error),
      );

  // ========================================
  // EN: Divider Theme
  // KO: 구분선 테마
  // ========================================
  static DividerThemeData get _dividerTheme =>
      const DividerThemeData(color: GBTColors.divider, thickness: 1, space: 1);

  static DividerThemeData get _darkDividerTheme => const DividerThemeData(
    color: GBTColors.darkBorder,
    thickness: 1,
    space: 1,
  );

  // ========================================
  // EN: Chip Theme
  // KO: 칩 테마
  // ========================================
  static ChipThemeData get _chipTheme => ChipThemeData(
    backgroundColor: GBTColors.surfaceVariant,
    selectedColor: GBTColors.primary,
    labelStyle: GBTTypography.labelMedium.copyWith(
      color: GBTColors.textSecondary,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: GBTSpacing.sm,
      vertical: GBTSpacing.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
    ),
  );

  static ChipThemeData get _darkChipTheme => ChipThemeData(
    backgroundColor: GBTColors.darkSurfaceVariant,
    selectedColor: GBTColors.secondary,
    labelStyle: GBTTypography.labelMedium.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: GBTSpacing.sm,
      vertical: GBTSpacing.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
    ),
  );

  // ========================================
  // EN: FAB Theme
  // KO: FAB 테마
  // ========================================
  static FloatingActionButtonThemeData get _fabTheme =>
      FloatingActionButtonThemeData(
        backgroundColor: GBTColors.secondary,
        foregroundColor: GBTColors.textInverse,
        elevation: GBTSpacing.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
        ),
      );

  // ========================================
  // EN: Bottom Sheet Theme
  // KO: 바텀 시트 테마
  // ========================================
  static BottomSheetThemeData get _bottomSheetTheme => BottomSheetThemeData(
    backgroundColor: GBTColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(GBTSpacing.radiusLg),
      ),
    ),
    elevation: GBTSpacing.elevationLg,
  );

  static BottomSheetThemeData get _darkBottomSheetTheme => BottomSheetThemeData(
    backgroundColor: GBTColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(GBTSpacing.radiusLg),
      ),
    ),
    elevation: GBTSpacing.elevationLg,
  );

  // ========================================
  // EN: Dialog Theme
  // KO: 다이얼로그 테마
  // ========================================
  static DialogThemeData get _dialogTheme => DialogThemeData(
    backgroundColor: GBTColors.background,
    elevation: GBTSpacing.elevationXl,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
    ),
    titleTextStyle: GBTTypography.titleLarge.copyWith(
      color: GBTColors.textPrimary,
    ),
    contentTextStyle: GBTTypography.bodyMedium.copyWith(
      color: GBTColors.textSecondary,
    ),
  );

  static DialogThemeData get _darkDialogTheme => DialogThemeData(
    backgroundColor: GBTColors.darkSurface,
    elevation: GBTSpacing.elevationXl,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
    ),
    titleTextStyle: GBTTypography.titleLarge.copyWith(
      color: GBTColors.darkTextPrimary,
    ),
    contentTextStyle: GBTTypography.bodyMedium.copyWith(
      color: GBTColors.darkTextSecondary,
    ),
  );

  // ========================================
  // EN: SnackBar Theme
  // KO: 스낵바 테마
  // ========================================
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
    backgroundColor: GBTColors.primary,
    contentTextStyle: GBTTypography.bodyMedium.copyWith(
      color: GBTColors.textInverse,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
    ),
  );

  // ========================================
  // EN: TabBar Theme
  // KO: 탭바 테마
  // ========================================
  static TabBarThemeData get _tabBarTheme => TabBarThemeData(
    labelColor: GBTColors.primary,
    unselectedLabelColor: GBTColors.textTertiary,
    labelStyle: GBTTypography.tabLabel,
    unselectedLabelStyle: GBTTypography.tabLabel,
    indicatorColor: GBTColors.primary,
    indicatorSize: TabBarIndicatorSize.label,
  );

  static TabBarThemeData get _darkTabBarTheme => TabBarThemeData(
    labelColor: GBTColors.secondary,
    unselectedLabelColor: GBTColors.darkTextTertiary,
    labelStyle: GBTTypography.tabLabel,
    unselectedLabelStyle: GBTTypography.tabLabel,
    indicatorColor: GBTColors.secondary,
    indicatorSize: TabBarIndicatorSize.label,
  );
}
