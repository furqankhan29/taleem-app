import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/extensions.dart';
import 'package:taleem/modules/attendance/controllers/attendance_history_controller.dart';
import 'package:taleem/modules/attendance/views/widgets/attendance_heatmap_widget.dart';
import 'package:taleem/modules/attendance/views/widgets/attendance_stats_widget.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/side_navigation_drawer.dart';

class AttendanceHistoryScreen extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.isDesktop ? null : AppBar(
        title: const Text('Attendance Dashboard'),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value && controller.attendanceHistory.isEmpty,
            child: ResponsiveLayout(
              mobile: (context) => _buildMobileLayout(context),
              desktop: (context) => _buildDesktopLayout(context),
            ),
          )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.attendanceMark),
        icon: const Icon(Icons.check_box_outlined),
        label: const Text('Mark Today'),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Select Batch selection
          _buildBatchDropdown(),
          const SizedBox(height: 16.0),

          // Statistics Bento Cards
          _buildStatsWidget(),
          const SizedBox(height: 16.0),

          // Heatmap grid (defaulting to current month)
          Obx(() => AttendanceHeatmapWidget(
                heatmapData: controller.heatmapData,
                month: DateTime.now(),
              )),
          const SizedBox(height: 16.0),

          // AI Insight Card
          _buildAiInsightCard(context),
          const SizedBox(height: 16.0),

          // Monthly Line Chart
          _buildTrendsChart(context),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        const SideNavigationDrawer(currentRoute: AppRoutes.attendance),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance Analytics',
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    _buildBatchDropdown(width: 250.0),
                  ],
                ),
                const SizedBox(height: 24.0),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Statistics & Heatmap
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildStatsWidget(),
                          const SizedBox(height: 16.0),
                          Obx(() => AttendanceHeatmapWidget(
                                heatmapData: controller.heatmapData,
                                month: DateTime.now(),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),

                    // Right Column: AI Insights & Line Graph trends
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildAiInsightCard(context),
                          const SizedBox(height: 16.0),
                          _buildTrendsChart(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchDropdown({double? width}) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        value: controller.selectedBatchId.value,
        items: const [
          DropdownMenuItem(value: 'CS-101', child: Text('CS-101 (Morning)')),
          DropdownMenuItem(value: 'PHY-202', child: Text('PHY-202 (Evening)')),
          DropdownMenuItem(value: 'MTH-303', child: Text('MTH-303 (Afternoon)')),
        ],
        onChanged: (val) {
          if (val != null) {
            controller.selectedBatchId.value = val;
            controller.loadAttendanceAnalytics();
          }
        },
        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16.0)),
      ),
    );
  }

  Widget _buildStatsWidget() {
    return Obx(() => AttendanceStatsWidget(
          present: controller.presentCount.value,
          absent: controller.absentCount.value,
          leave: controller.leaveCount.value,
          lateDays: controller.lateCount.value,
          percentage: controller.attendancePercentage.value,
          streak: controller.currentStreak.value,
        ));
  }

  Widget _buildAiInsightCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primary, width: 4.0),
          ),
        ),
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'AI Attendance Insight',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Obx(() => Text(
                  controller.aiAttendanceInsight.value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                    height: 1.5,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: SizedBox(
        height: 250.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Attendance Trends (Last 6 Months)',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? const Color(0x1BFFFFFF) : const Color(0x1A000000),
                        strokeWidth: 1.0,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: AppColors.outline,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('Sep', style: style);
                              break;
                            case 1:
                              text = const Text('Oct', style: style);
                              break;
                            case 2:
                              text = const Text('Nov', style: style);
                              break;
                            case 3:
                              text = const Text('Dec', style: style);
                              break;
                            case 4:
                              text = const Text('Jan', style: style);
                              break;
                            case 5:
                              text = const Text('Feb', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 4.0,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: AppColors.outline,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.monthlyTrends.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.secondary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.secondary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
