import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class RecentActivitiesCard extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivitiesCard({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
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
          ...activities.map((act) => _buildActivityItem(act)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> act) {
    final IconData icon;
    final Color color;

    switch (act['icon']) {
      case 'person_add':
        icon = Icons.person_add_rounded;
        color = AppColors.primary;
        break;
      case 'payments':
        icon = Icons.payments_rounded;
        color = AppColors.secondary;
        break;
      case 'warning':
        icon = Icons.warning_rounded;
        color = AppColors.error;
        break;
      default:
        icon = Icons.history_rounded;
        color = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act['title'] ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  act['time'] ?? '',
                  style: AppTypography.labelCaps.copyWith(
                    fontSize: 9.0,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
