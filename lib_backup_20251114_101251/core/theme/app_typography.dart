import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'SF Pro';

  static TextTheme lightTextTheme = const TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 44,
      letterSpacing: -1.2,
      color: AppColors.lightTextPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 36,
      letterSpacing: -1.0,
      color: AppColors.lightTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      letterSpacing: -0.6,
      color: AppColors.lightTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      letterSpacing: -0.4,
      color: AppColors.lightTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: AppColors.lightTextPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: AppColors.lightTextSecondary,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: AppColors.lightTextSecondary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: AppColors.lightTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 15,
      color: AppColors.lightTextSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      color: AppColors.lightTextSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 13,
      letterSpacing: 0.3,
      color: AppColors.lightTextPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      color: AppColors.lightTextSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      color: AppColors.lightTextSecondary,
    ),
  );

  static TextTheme darkTextTheme = const TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 44,
      letterSpacing: -1.2,
      color: AppColors.darkTextPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 36,
      letterSpacing: -1.0,
      color: AppColors.darkTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      letterSpacing: -0.6,
      color: AppColors.darkTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      letterSpacing: -0.4,
      color: AppColors.darkTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: AppColors.darkTextPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: AppColors.darkTextSecondary,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: AppColors.darkTextSecondary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: AppColors.darkTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 15,
      color: AppColors.darkTextSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      color: AppColors.darkTextSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 13,
      letterSpacing: 0.3,
      color: AppColors.darkTextPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      color: AppColors.darkTextSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      color: AppColors.darkTextSecondary,
    ),
  );
}
