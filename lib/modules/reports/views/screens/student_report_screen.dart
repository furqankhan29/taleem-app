import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/modules/reports/controllers/student_report_controller.dart';
import 'package:taleem/modules/reports/views/widgets/report_chart_widget.dart';
import 'package:taleem/modules/reports/views/widgets/report_table_widget.dart';
import 'package:taleem/modules/reports/views/widgets/report_filter_bar.dart';
import 'package:taleem/modules/reports/views/widgets/ai_insight_card.dart';
import 'package:taleem/modules/reports/views/widgets/export_button_group.dart';
import 'package:taleem/modules/reports/controllers/export_controller.dart';
import 'package:taleem/data/models/report_model.dart';

class StudentReportScreen extends GetView<StudentReportController> {
  const StudentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exportCtrl = Get.find<ExportController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Student Report')),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(controller.error.value!),
              ],
            ),
          );
        }

        final data = controller.analytics.value;
        if (data == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportFilterBar(
                filter: controller.filter,
                onChanged: controller.setFilter,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MetricCard(label: 'Total', value: '${data.metrics['total'] ?? 0}', color: AppColors.primary),
                  const SizedBox(width: 8),
                  _MetricCard(label: 'Active', value: '${data.metrics['active'] ?? 0}', color: AppColors.secondary),
                  const SizedBox(width: 8),
                  _MetricCard(label: 'Inactive', value: '${data.metrics['inactive'] ?? 0}', color: AppColors.error),
                ],
              ),
              const SizedBox(height: 16),
              if (data.aiInsight != null) ...[
                AiInsightCard(insight: data.aiInsight!),
                const SizedBox(height: 16),
              ],
              ExportButtonGroup(
                exporting: exportCtrl.exporting,
                onPdfExport: () => exportCtrl.exportToPdf(
                  title: 'Student Report',
                  type: ReportType.performance,
                  data: data.metrics,
                  filter: controller.filter.value,
                ),
                onExcelExport: () {
                  final headers = data.tables.isNotEmpty
                      ? ((data.tables.first['headers'] as List?)?.cast<String>() ?? [])
                      : <String>[];
                  final rows = data.tables.expand((t) {
                    return (t['rows'] as List?)?.cast<List<dynamic>>().map((row) {
                      final map = <String, dynamic>{};
                      for (int i = 0; i < headers.length && i < row.length; i++) {
                        map[headers[i]] = row[i];
                      }
                      return map;
                    }).toList() ?? <Map<String, dynamic>>[];
                  }).toList();
                  exportCtrl.exportToExcel(
                    title: 'Student Data',
                    rows: rows,
                    columns: headers,
                  );
                },
              ),
              const SizedBox(height: 16),
              ...data.charts.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ReportChartWidget(chart: c),
              )),
              ...data.tables.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ReportTableWidget(table: t),
              )),
            ],
          ),
        );
      }),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: color,
            )),
            Text(label, style: TextStyle(
              fontSize: 12, color: color.withValues(alpha: 0.7),
            )),
          ],
        ),
      ),
    );
  }
}
