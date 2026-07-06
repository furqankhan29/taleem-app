import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/shared/widgets/avatar_stack.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class UpcomingClassesCard extends StatelessWidget {
  final List<Map<String, dynamic>> classes;

  const UpcomingClassesCard({
    super.key,
    required this.classes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Classes',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ...classes.map((cls) => _buildClassItem(context, cls, isDark)),
        ],
      ),
    );
  }

  Widget _buildClassItem(BuildContext context, Map<String, dynamic> cls, bool isDark) {
    final Color borderAccentColor;
    switch (cls['type']) {
      case 'physics':
        borderAccentColor = AppColors.primary;
        break;
      case 'history':
        borderAccentColor = AppColors.secondary;
        break;
      default:
        borderAccentColor = AppColors.tertiary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerLowestDark : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.regular),
        border: Border(
          left: BorderSide(color: borderAccentColor, width: 4.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cls['time'] ?? '',
                  style: AppTypography.labelCaps.copyWith(
                    color: borderAccentColor,
                    fontSize: 10.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  cls['title'] ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    AvatarStack(
                      imageUrls: List<String>.from(cls['students'] ?? []),
                      size: 20.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '+${cls['extraStudents']}',
                      style: AppTypography.labelCaps.copyWith(
                        fontSize: 9.0,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.surfaceContainerHighDark : AppColors.primaryContainer.withValues(alpha: 0.15),
              foregroundColor: AppColors.primary,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12.0),
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 24.0),
          ),
        ],
      ),
    );
  }
}
