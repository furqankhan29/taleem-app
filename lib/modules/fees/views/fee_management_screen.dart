import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/core/utils/extensions.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/modules/fees/controllers/fee_controller.dart';
import 'package:taleem/modules/fees/views/widgets/fee_stat_card.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/side_navigation_drawer.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class FeeManagementScreen extends GetView<FeeController> {
  const FeeManagementScreen({super.key});

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter Payments',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            
            // Payment Status Filter
            DropdownButtonFormField<FeePaymentStatus>(
              value: controller.selectedStatus.value,
              hint: const Text('Select Status'),
              items: FeePaymentStatus.values.map((s) {
                return DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst!));
              }).toList(),
              onChanged: (val) {
                controller.selectedStatus.value = val;
              },
            ),
            const SizedBox(height: 12.0),

            // Fee Type Filter
            DropdownButtonFormField<FeeType>(
              value: controller.selectedType.value,
              hint: const Text('Select Category'),
              items: FeeType.values.map((t) {
                return DropdownMenuItem(value: t, child: Text(t.name.capitalizeFirst!));
              }).toList(),
              onChanged: (val) {
                controller.selectedType.value = val;
              },
            ),
            const SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: () {
                controller.loadFinancialData();
                Get.back();
              },
              child: const Text('Apply Filters'),
            ),
            const SizedBox(height: 8.0),
            OutlinedButton(
              onPressed: () {
                controller.selectedStatus.value = null;
                controller.selectedType.value = null;
                controller.loadFinancialData();
                Get.back();
              },
              child: const Text('Reset All'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.isDesktop ? null : AppBar(
        title: const Text('Fee Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: controller.exportToCSV,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value && controller.feesList.isEmpty,
            child: ResponsiveLayout(
              mobile: (context) => _buildMobileLayout(context),
              desktop: (context) => _buildDesktopLayout(context),
            ),
          )),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadFinancialData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analytics Row
            _buildStatsGrid(),
            const SizedBox(height: 16.0),

            // FlChart Line graph trends
            _buildRevenueChart(context),
            const SizedBox(height: 16.0),

            // Invoices Header / Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outstanding Ledger',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Records: ${controller.feesList.length}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Invoice list
            _buildLedgerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        const SideNavigationDrawer(currentRoute: AppRoutes.feeManagement),
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
                      'Financial Dashboard',
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: controller.exportToCSV,
                          icon: const Icon(Icons.download_rounded, size: 16.0),
                          label: const Text('Export CSV'),
                        ),
                        const SizedBox(width: 12.0),
                        OutlinedButton.icon(
                          onPressed: () => _showFilterSheet(context),
                          icon: const Icon(Icons.filter_list_rounded, size: 16.0),
                          label: const Text('Filters'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Statistics & Ledger list
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStatsGrid(),
                          const SizedBox(height: 20.0),
                          Text(
                            'Outstanding Ledger',
                            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12.0),
                          _buildLedgerList(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20.0),

                    // Right Column: Revenue Trends Graph & Advanced options
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _buildRevenueChart(context),
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

  Widget _buildStatsGrid() {
    return Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: Get.context!.isMobile ? 2 : 3,
          childAspectRatio: 1.6,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          children: [
            FeeStatCard(
              title: 'Total Collected',
              value: Formatters.toCurrency(controller.totalCollected.value),
              icon: Icons.payments_outlined,
              color: AppColors.secondary,
            ),
            FeeStatCard(
              title: 'Pending Dues',
              value: Formatters.toCurrency(controller.totalPending.value),
              icon: Icons.hourglass_empty_rounded,
              color: AppColors.tertiary,
            ),
            FeeStatCard(
              title: 'Recovery Rate',
              value: '${controller.recoveryPercentage.value.toStringAsFixed(1)}%',
              icon: Icons.trending_up_rounded,
              color: AppColors.primary,
            ),
          ],
        ));
  }

  Widget _buildRevenueChart(BuildContext context) {
    return GlassCard(
      child: SizedBox(
        height: 250.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Collected Revenue (Last 6 Months)',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
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
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: controller.revenueTrends.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: AppColors.primary,
                          width: 14.0,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerList() {
    return Obx(() => controller.feesList.isEmpty
        ? const EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No Invoices Found',
            subtitle: 'Try adjusting filters or check your connection status.',
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.feesList.length,
            itemBuilder: (context, index) {
              final fee = controller.feesList[index];
              final student = controller.studentsList.firstWhereOrNull((s) => s.id == fee.studentId);
              final isPaid = fee.status == FeePaymentStatus.paid;
              final chipColor = isPaid
                  ? Colors.green
                  : (fee.status == FeePaymentStatus.partial ? Colors.orange : Colors.red);

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  student?.name ?? 'Loading Student...',
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8.0),
                                StatusChip(
                                  label: fee.status.name,
                                  color: chipColor,
                                  textColor: chipColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Category: ${fee.type.name.capitalizeFirst} | Term: ${fee.term ?? "Monthly"}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Due Date: ${Formatters.formatDate(fee.dueDate)}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.outline, fontSize: 11.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.toCurrency(fee.amount),
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (fee.balanceDue > 0)
                            Text(
                              'Due: ${Formatters.toCurrency(fee.balanceDue)}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.tertiary, fontWeight: FontWeight.bold, fontSize: 11.0),
                            ),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () => Get.toNamed(AppRoutes.feeCollection, arguments: fee),
                            child: Text(isPaid ? 'Details' : 'Collect'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ));
  }
}
