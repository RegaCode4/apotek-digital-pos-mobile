import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Helper style neubrutalism lembut khas Apotek Digital Web:
/// - Border solid tebal (2px)
/// - Bayangan tajam tanpa blur (BoxShadow dengan blurRadius = 0)
/// - Sudut rounded (12px - 14px)
class NeubrutalStyle {
  static BoxDecoration card({
    Color backgroundColor = AppColors.surface,
    Color borderColor = AppColors.darkBrutal,
    double borderWidth = 2.0,
    double borderRadius = 12.0,
    double shadowOffset = 4.0,
    Color shadowColor = AppColors.darkBrutal,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        if (shadowOffset > 0)
          BoxShadow(
            color: shadowColor,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          ),
      ],
    );
  }

  static BoxDecoration badge({
    required Color backgroundColor,
    Color borderColor = AppColors.darkBrutal,
    double borderRadius = 6.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.5),
    );
  }
}
