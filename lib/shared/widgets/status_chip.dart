import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';

enum StatusChipSize { small, medium }

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final StatusChipSize size;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
    this.size = StatusChipSize.small,
  });

  @override
  Widget build(BuildContext context) {
    final padding = size == StatusChipSize.small
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)
        : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);

    final textStyle = AppTypography.labelCaps.copyWith(
      color: textColor,
      fontSize: size == StatusChipSize.small ? 10.0 : 12.0,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: size == StatusChipSize.small ? 12.0 : 14.0,
              color: textColor,
            ),
            const SizedBox(width: 4.0),
          ],
          Text(
            label.toUpperCase(),
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
