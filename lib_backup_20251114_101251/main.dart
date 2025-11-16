import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/persistence/selection_persistence.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Initialize selection persistence (load + watch changes)
    ref.watch(selectionPersistenceProvider);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.lightTextTheme,
      colorScheme: const ColorScheme.light(
      primary: AppColors.lightAccent,
      onPrimary: Colors.white,
      secondary: AppColors.lightAccentSecondary,
      onSecondary: AppColors.lightTextPrimary,
      tertiary: AppColors.lightAccentTertiary,
      onTertiary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.lightError,
      onError: Colors.white,
    ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightCardOutline),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.lightAccent,
        unselectedItemColor: AppColors.lightTextSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedColor: AppColors.lightAccent.withValues(alpha: 0.12),
        secondarySelectedColor: AppColors.lightAccent,
        labelStyle: AppTypography.lightTextTheme.labelLarge!,
        secondaryLabelStyle:
            AppTypography.lightTextTheme.labelLarge!.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.lightAccent,
        scaffoldBackgroundColor: AppColors.lightBackground,
        barBackgroundColor: Color(0xF2FFFFFF),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.darkTextTheme,
      colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccentSecondary,
      onPrimary: Colors.black,
      secondary: AppColors.darkAccent,
      onSecondary: Colors.black,
      tertiary: AppColors.darkAccentTertiary,
      onTertiary: Colors.black,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.darkError,
      onError: Colors.black,
    ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkCardOutline),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.darkAccent,
        unselectedItemColor: AppColors.darkTextSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        selectedColor: AppColors.darkAccentSecondary.withValues(alpha: 0.18),
        secondarySelectedColor: AppColors.darkAccent,
        labelStyle: AppTypography.darkTextTheme.labelLarge!,
        secondaryLabelStyle:
            AppTypography.darkTextTheme.labelLarge!.copyWith(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.darkAccent,
        scaffoldBackgroundColor: AppColors.darkBackground,
        barBackgroundColor: Color(0xCC141A29),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.darkTextPrimary,
          ),
        ),
      ),
    );

    return MaterialApp.router(
      title: '걸즈밴드타비',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
