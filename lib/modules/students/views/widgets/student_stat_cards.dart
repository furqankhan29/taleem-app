import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class StudentStatCards extends StatelessWidget {
  final String rank;
  final String demerits;
  final String feeStatus;
  final String awards;

  const StudentStatCards({
    super.key,
    required this.rank,
    required this.demerits,
    required this.feeStatus,
    required this.awards,
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
          title: 'Class Rank',
          value: rank,
          icon: Icons.emoji_events_outlined,
          color: AppColors.primary,
        ),
        _buildStatCard(
          context,
          title: 'Demerits',
          value: demerits,
          icon: Icons.error_outline_rounded,
          color: AppColors.tertiary,
        ),
        _buildStatCard(
          context,
          title: 'Fee Status',
          value: feeStatus,
          icon: Icons.payments_outlined,
          color: AppColors.secondary,
          valueColor: feeStatus == 'Cleared' ? AppColors.secondary : AppColors.error,
        ),
        _buildStatCard(
          context,
          title: 'Awards',
          value: awards,
          icon: Icons.verified_outlined,
          color: AppColors.primary,
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
    Color? valueColor,
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
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
