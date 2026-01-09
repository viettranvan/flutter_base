import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

/// Pre-defined typography styles for the app
/// For custom styles, use [AppTextStyle.of()] method
class AppTypography {
  AppTypography._();

  // Headline Styles
  static TextStyle get headline1 => AppTextStyle.of(
        size: 32,
        weight: AppFontWeight.bold,
        height: 1.2,
      );

  static TextStyle get headline2 => AppTextStyle.of(
        size: 28,
        weight: AppFontWeight.bold,
        height: 1.2,
      );

  static TextStyle get headline3 => AppTextStyle.of(
        size: 24,
        weight: AppFontWeight.semiBold,
        height: 1.3,
      );

  static TextStyle get headline4 => AppTextStyle.of(
        size: 20,
        weight: AppFontWeight.semiBold,
        height: 1.4,
      );

  // Body Styles
  static TextStyle get bodyLarge => AppTextStyle.of(
        size: 18,
        weight: AppFontWeight.regular,
        height: 1.5,
      );

  static TextStyle get bodyMedium => AppTextStyle.of(
        size: 16,
        weight: AppFontWeight.regular,
        height: 1.5,
      );

  static TextStyle get bodySmall => AppTextStyle.of(
        size: 14,
        weight: AppFontWeight.regular,
        height: 1.5,
      );

  // Label Styles
  static TextStyle get labelLarge => AppTextStyle.of(
        size: 14,
        weight: AppFontWeight.semiBold,
        height: 1.4,
      );

  static TextStyle get labelMedium => AppTextStyle.of(
        size: 12,
        weight: AppFontWeight.medium,
        height: 1.4,
      );

  static TextStyle get labelSmall => AppTextStyle.of(
        size: 11,
        weight: AppFontWeight.medium,
        height: 1.3,
      );

  // Display Styles
  static TextStyle get displayLarge => AppTextStyle.of(
        size: 57,
        weight: AppFontWeight.bold,
        height: 1.1,
      );

  static TextStyle get displayMedium => AppTextStyle.of(
        size: 45,
        weight: AppFontWeight.bold,
        height: 1.2,
      );

  static TextStyle get displaySmall => AppTextStyle.of(
        size: 36,
        weight: AppFontWeight.bold,
        height: 1.2,
      );
}
