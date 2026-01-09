import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

enum AppFontWeight {
  thin(FontWeight.w100),
  extraLight(FontWeight.w200),
  light(FontWeight.w300),
  regular(FontWeight.w400),
  medium(FontWeight.w500),
  semiBold(FontWeight.w600),
  bold(FontWeight.w700),
  extraBold(FontWeight.w800),
  black(FontWeight.w900),
  ;

  const AppFontWeight(this.fontWeight);
  final FontWeight fontWeight;
}

class AppTypography {
  AppTypography._();

  static TextStyle get headline1 => AppTypography.of(
        size: 32,
        weight: AppFontWeight.bold,
        height: 1.2,
      );

  static TextStyle of({
    double? size,
    Color color = AppColors.primaryBrand500,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    AppFontWeight weight = AppFontWeight.regular,
  }) {
    return TextStyle(
      fontSize: size,
      color: color,
      height: height ?? 1.2,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontWeight: weight.fontWeight,
    );
  }
}
