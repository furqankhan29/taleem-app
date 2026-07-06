import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/attendance_model.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class AttendanceHeatmapWidget extends StatelessWidget {
  final Map<DateTime, AttendanceStatus> heatmapData;
  final DateTime month;

  const AttendanceHeatmapWidget({
    super.key,
    required this.heatmapData,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate days of the month
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Heatmap',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_getMonthName(month.month)} ${month.year}',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          
          // Day initials headers: Mon, Tue, etc.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 24.0,
                child: Text(
                  day,
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),

          // Heatmap Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 weeks maximum row space
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6.0,
              crossAxisSpacing: 6.0,
            ),
            itemBuilder: (context, index) {
              // Offset calculation for day positioning
              final dayIndex = index - (startWeekday - 1) + 1;

              if (dayIndex <= 0 || dayIndex > daysInMonth) {
                return const SizedBox.shrink(); // empty cell
              }

              final dayDate = DateTime(month.year, month.month, dayIndex);
              final status = heatmapData[dayDate];

              return _buildDayBox(dayIndex, status, isDark);
            },
          ),
          
          const SizedBox(height: 16.0),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Present', AppColors.primary),
              const SizedBox(width: 12.0),
              _buildLegendItem('Absent', AppColors.tertiary),
              const SizedBox(width: 12.0),
              _buildLegendItem('Late', AppColors.secondary),
              const SizedBox(width: 12.0),
              _buildLegendItem('Leave', AppColors.outlineVariant),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayBox(int day, AttendanceStatus? status, bool isDark) {
    Color boxColor;
    Color textColor;

    switch (status) {
      case AttendanceStatus.present:
        boxColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case AttendanceStatus.absent:
        boxColor = AppColors.tertiary;
        textColor = Colors.white;
        break;
      case AttendanceStatus.late:
        boxColor = AppColors.secondary;
        textColor = Colors.white;
        break;
      case AttendanceStatus.leave:
        boxColor = AppColors.outlineVariant.withValues(alpha: 0.3);
        textColor = AppColors.outline;
        break;
      default:
        boxColor = isDark ? Colors.white12 : Colors.black12.withValues(alpha: 0.04);
        textColor = AppColors.outline;
    }

    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(AppRadius.regular),
        border: Border.all(
          color: status != null ? Colors.transparent : (isDark ? Colors.white24 : Colors.black12),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 11.0,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: 4.0),
        Text(
          label,
          style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getMonthName(int monthNum) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[monthNum - 1];
  }
}
