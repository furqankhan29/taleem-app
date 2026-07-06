import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_shadows.dart';

class AmbientShadowContainer extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AmbientShadowContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.color,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final containerRadius = BorderRadius.circular(borderRadius ?? AppRadius.lg);
    
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: containerRadius,
        boxShadow: AppShadows.ambientShadow,
      ),
      child: ClipRRect(
        borderRadius: containerRadius,
        child: child,
      ),
    );
  }
}
