import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/services/report_service.dart';

class ReportFilterBar extends StatelessWidget {
  final Rx<ReportFilter> filter;
  final Function(ReportFilter) onChanged;

  const ReportFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPeriod = filter.value.period;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ReportPeriod.values.map((period) {
                  final selected = period == currentPeriod;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period.label),
                      selected: selected,
                      onSelected: (_) {
                        if (!selected) {
                          onChanged(filter.value.copyWith(period: period));
                        }
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.outline,
                      ),
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.onSurface,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (currentPeriod == ReportPeriod.custom) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Start Date',
                      value: filter.value.startDate,
                      onPicked: (d) => onChanged(filter.value.copyWith(startDate: d)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'End Date',
                      value: filter.value.endDate,
                      onPicked: (d) => onChanged(filter.value.copyWith(endDate: d)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;

  const _DateField({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              value != null
                  ? '${value!.day}/${value!.month}/${value!.year}'
                  : label,
              style: AppTypography.bodySmall.copyWith(
                color: value != null ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
