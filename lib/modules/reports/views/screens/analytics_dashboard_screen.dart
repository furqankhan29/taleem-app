import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/modules/reports/controllers/analytics_controller.dart';
import 'package:taleem/modules/reports/views/widgets/kpi_metrics_row.dart';
import 'package:taleem/modules/reports/views/widgets/report_chart_widget.dart';
import 'package:taleem/modules/reports/views/widgets/report_table_widget.dart';
import 'package:taleem/modules/reports/views/widgets/report_filter_bar.dart';
import 'package:taleem/modules/reports/views/widgets/ai_insight_card.dart';
import 'package:taleem/modules/reports/views/widgets/export_button_group.dart';
import 'package:taleem/modules/reports/controllers/export_controller.dart';
import 'package:taleem/data/models/report_model.dart';

class AnalyticsDashboardScreen extends GetView<AnalyticsController> {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exportCtrl = Get.put(ExportController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadData,
          ),
        ],
      ),
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
                Text(controller.error.value!, style: AppTypography.bodyMedium),
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
              KpiMetricsRow(metrics: controller.kpiMetrics),
              const SizedBox(height: 16),
              if (data.aiInsight != null) ...[
                AiInsightCard(insight: data.aiInsight!),
                const SizedBox(height: 16),
              ],
              ExportButtonGroup(
                exporting: exportCtrl.exporting,
                onPdfExport: () => exportCtrl.exportToPdf(
                  title: 'Analytics Dashboard Report',
                  type: ReportType.income,
                  data: data.metrics,
                  filter: controller.filter.value,
                ),
                onExcelExport: () {
                  final rows = data.tables.expand((t) {
                    final headers = (t['headers'] as List?)?.cast<String>() ?? [];
                    return (t['rows'] as List?)?.cast<List<dynamic>>().map((row) {
                      final map = <String, dynamic>{};
                      for (int i = 0; i < headers.length && i < row.length; i++) {
                        map[headers[i]] = row[i];
                      }
                      return map;
                    }).toList() ?? <Map<String, dynamic>>[];
                  }).toList();
                  final headers = data.tables.isNotEmpty
                      ? ((data.tables.first['headers'] as List?)?.cast<String>() ?? [])
                      : <String>[];
                  exportCtrl.exportToExcel(
                    title: 'Analytics Dashboard Data',
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
