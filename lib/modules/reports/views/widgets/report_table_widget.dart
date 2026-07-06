import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';

class ReportTableWidget extends StatelessWidget {
  final Map<String, dynamic> table;

  const ReportTableWidget({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final title = table['title'] as String? ?? '';
    final headers = (table['headers'] as List?)?.cast<String>() ?? [];
    final rows = (table['rows'] as List?)?.cast<List<dynamic>>() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: AppTypography.titleLarge),
            const SizedBox(height: 12),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
              dataRowColor: WidgetStateProperty.all(Colors.transparent),
              border: TableBorder(
                horizontalInside: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
              ),
              columns: headers.map((h) => DataColumn(
                label: Text(h, style: AppTypography.labelCaps.copyWith(fontWeight: FontWeight.bold)),
              )).toList(),
              rows: rows.map((row) => DataRow(
                cells: row.map((cell) => DataCell(
                  Text(cell.toString(), style: AppTypography.bodySmall),
                )).toList(),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
