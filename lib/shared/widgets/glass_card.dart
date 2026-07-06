import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_shadows.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double elevation;
  final Color? borderColor;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.margin,
    this.onTap,
    this.elevation = 0,
    this.borderColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final cardBorderRadius = BorderRadius.circular(borderRadius ?? AppRadius.xl);
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.surfaceGlassDark : AppColors.surfaceGlass),
        borderRadius: cardBorderRadius,
        border: Border.all(
          color: borderColor ?? (isDark ? const Color(0x1BFFFFFF) : const Color(0xCCFFFFFF)),
          width: 1.0,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: cardContent,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: cardBorderRadius,
        boxShadow: elevation > 0 ? AppShadows.elevatedShadow : AppShadows.glassShadow,
      ),
      child: ClipRRect(
        borderRadius: cardBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: cardContent,
        ),
      ),
    );
  }
}
