import 'package:design_assets/design_assets.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.onPressed,
    required this.title,
    this.btnColor,
    this.height,
  });

  final VoidCallback? onPressed;
  final String title;
  final Color? btnColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height ?? 54,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: btnColor ?? AppColors.primaryBrand900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyle.of(
              size: 16,
              color: AppColors.white900,
              weight: AppFontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
