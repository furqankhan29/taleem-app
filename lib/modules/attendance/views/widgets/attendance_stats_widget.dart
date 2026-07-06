import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class AttendanceStatsWidget extends StatelessWidget {
  final int present;
  final int absent;
  final int leave;
  final int lateDays;
  final double percentage;
  final int streak;

  const AttendanceStatsWidget({
    super.key,
    required this.present,
    required this.absent,
    required this.leave,
    required this.lateDays,
    required this.percentage,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12.0,
      crossAxisSpacing: 12.0,
      children: [
        _buildStatCard(
          context,
          title: 'Attendance Rate',
          value: '${percentage.toStringAsFixed(1)}%',
          icon: Icons.percent_rounded,
          color: AppColors.primary,
        ),
        _buildStatCard(
          context,
          title: 'Active Streak',
          value: '$streak Days',
          icon: Icons.local_fire_department_rounded,
          color: Colors.orange,
        ),
        _buildStatCard(
          context,
          title: 'Present / Late',
          value: '$present / $lateDays',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.secondary,
        ),
        _buildStatCard(
          context,
          title: 'Absent / Leave',
          value: '$absent / $leave',
          icon: Icons.cancel_outlined,
          color: AppColors.tertiary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 20.0,
              ),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
