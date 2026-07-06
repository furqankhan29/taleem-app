import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/calendar_event_model.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class EventCard extends StatelessWidget {
  final CalendarEventModel event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _eventColor;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      borderColor: color.withValues(alpha: 0.3),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(event.date),
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    if (event.endDate != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        ' - ${DateFormat('MMM d, yyyy').format(event.endDate!)}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
                if (event.description != null && event.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildTypeChip(),
        ],
      ),
    );
  }

  Widget _buildTypeChip() {
    final typeLabel = event.type.name.toUpperCase();
    final color = _eventColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        typeLabel,
        style: AppTypography.labelCaps.copyWith(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  Color get _eventColor {
    switch (event.type) {
      case CalendarEventType.holiday:
        return Colors.green;
      case CalendarEventType.exam:
        return Colors.red;
      case CalendarEventType.ptm:
        return Colors.orange;
      case CalendarEventType.deadline:
        return Colors.purple;
      case CalendarEventType.event:
        return Colors.blue;
    }
  }
}
