import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get glassShadow => [
        const BoxShadow(
          color: Color(0x0D000000), // 5% black
          offset: Offset(0, 4),
          blurRadius: 6.0,
          spreadRadius: -1.0,
        ),
        const BoxShadow(
          color: Color(0x08000000), // 3% black
          offset: Offset(0, 2),
          blurRadius: 4.0,
          spreadRadius: -1.0,
        ),
      ];

  static List<BoxShadow> get ambientShadow => [
        const BoxShadow(
          color: AppColors.ambientShadow, // indigo-tinted shadow
          offset: Offset(0, 10),
          blurRadius: 30.0,
          spreadRadius: -10.0,
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        const BoxShadow(
          color: Color(0x262C2ABC), // 15% primary
          offset: Offset(0, 10),
          blurRadius: 30.0,
          spreadRadius: -10.0,
        ),
      ];
}
