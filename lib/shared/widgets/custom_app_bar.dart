import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onMenuTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Mobile/Tablet vs Desktop layout check
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      // Desktop doesn't use a mobile-style app bar, but if used, we show it transparent
      return Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
            ),
            if (actions != null) Row(children: actions!),
          ],
        ),
      );
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: AppBar(
          backgroundColor: isDark ? AppColors.backgroundDark.withValues(alpha: 0.6) : AppColors.surfaceGlass,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                  onPressed: () => Get.back(),
                )
              : onMenuTap != null
                  ? IconButton(
                      icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
                      onPressed: onMenuTap,
                    )
                  : null,
          title: Text(
            title,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          actions: actions,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: isDark ? const Color(0x1BFFFFFF) : const Color(0x1A000000),
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}
