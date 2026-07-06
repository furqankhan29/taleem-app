import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class ActivityTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> logs;

  const ActivityTimeline({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_toggle_off_rounded,
                color: AppColors.primary,
                size: 22.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Activity Log',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              return _buildTimelineItem(
                context,
                logs[index],
                isLast: index == logs.length - 1,
              );
            },
          ),
          const SizedBox(height: 16.0),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            child: const Text('View Full History'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> log, {required bool isLast}) {
    final IconData icon;
    final Color color;

    switch (log['icon']) {
      case 'assessment':
        icon = Icons.assessment_rounded;
        color = AppColors.primary;
        break;
      case 'event_busy':
        icon = Icons.event_busy_rounded;
        color = AppColors.error;
        break;
      case 'payments':
        icon = Icons.payments_rounded;
        color = AppColors.secondary;
        break;
      case 'forum':
        icon = Icons.forum_rounded;
        color = AppColors.primary;
        break;
      default:
        icon = Icons.history_rounded;
        color = AppColors.primary;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side Timeline line and icon
          Column(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: color,
                  size: 18.0,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16.0),
          
          // Right side Text details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log['title'] ?? '',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    log['subtitle'] ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    log['time'] ?? '',
                    style: AppTypography.labelCaps.copyWith(
                      fontSize: 10.0,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
