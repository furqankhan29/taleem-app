import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/extensions.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:taleem/modules/dashboard/views/widgets/ai_insights_card.dart';
import 'package:taleem/modules/dashboard/views/widgets/kpi_card.dart';
import 'package:taleem/modules/dashboard/views/widgets/monthly_income_chart.dart';
import 'package:taleem/modules/dashboard/views/widgets/recent_activities_card.dart';
import 'package:taleem/modules/dashboard/views/widgets/upcoming_classes_card.dart';
import 'package:taleem/shared/widgets/bottom_nav_bar.dart';
import 'package:taleem/shared/widgets/custom_app_bar.dart';
import 'package:taleem/shared/widgets/custom_fab.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/search_field.dart';
import 'package:taleem/shared/widgets/side_navigation_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      appBar: context.isDesktop ? null : CustomAppBar(
        title: 'Taleem',
        onMenuTap: () {},
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: ResponsiveLayout(
        mobile: (context) => _buildMobileLayout(context, controller),
        desktop: (context) => _buildDesktopLayout(context, controller),
      ),
      bottomNavigationBar: context.isDesktop 
          ? null 
          : BottomNavBar(
              currentIndex: 0, 
              onTap: (index) {
                // Handle tab switching
                if (index == 1) Get.toNamed(AppRoutes.studentList);
                if (index == 2) Get.toNamed(AppRoutes.attendance);
                if (index == 3) Get.toNamed(AppRoutes.aiAssistant);
              },
            ),
      floatingActionButton: context.isDesktop 
          ? null 
          : CustomFab(
              onTap: () {
                // Add quick action dialog
                Helpers.showSnackbar(title: 'Quick Action', message: 'Add item requested');
              },
            ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DashboardController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGreetingHeader(),
            const SizedBox(height: 24.0),
            
            // Stats grid
            Obx(() => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 12.0,
                  children: [
                    KpiCard(
                      icon: Icons.group_outlined,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryFixed,
                      trendValue: '12%',
                      trendPositive: true,
                      label: 'Total Students',
                      value: controller.totalStudents.value.toCompact(),
                    ),
                    KpiCard(
                      icon: Icons.school_outlined,
                      iconColor: AppColors.secondary,
                      iconBgColor: AppColors.successContainer,
                      trendValue: '5%',
                      trendPositive: true,
                      label: 'Active Now',
                      value: controller.activeNow.value.toCompact(),
                    ),
                    KpiCard(
                      icon: Icons.fact_check_outlined,
                      iconColor: AppColors.error,
                      iconBgColor: AppColors.warningContainer,
                      trendValue: '2%',
                      trendPositive: false,
                      label: 'Attendance',
                      value: '${controller.attendanceRate.value.toStringAsFixed(1)}%',
                    ),
                    KpiCard(
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.surfaceDim,
                      trendValue: '8%',
                      trendPositive: true,
                      label: 'Fee Collection',
                      value: '\$${controller.feeCollection.value.toStringAsFixed(1)}k',
                    ),
                  ],
                )),
            const SizedBox(height: 16.0),
            
            const AiInsightsCard(),
            const SizedBox(height: 16.0),
            
            SizedBox(
              height: 350,
              child: Obx(() => MonthlyIncomeChart(
                    incomeData: controller.monthlyIncomeData,
                  )),
            ),
            const SizedBox(height: 16.0),
            
            Obx(() => UpcomingClassesCard(
                  classes: controller.upcomingClasses,
                )),
            const SizedBox(height: 16.0),
            
            Obx(() => RecentActivitiesCard(
                  activities: controller.recentActivities,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DashboardController controller) {
    return Row(
      children: [
        const SideNavigationDrawer(currentRoute: AppRoutes.dashboard),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDesktopHeader(context),
                const SizedBox(height: 32.0),
                
                // Bento grid row 1: KPIs + AI Insights
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Obx(() => GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 16.0,
                            children: [
                              KpiCard(
                                icon: Icons.group_outlined,
                                iconColor: AppColors.primary,
                                iconBgColor: AppColors.primaryFixed,
                                trendValue: '12%',
                                trendPositive: true,
                                label: 'Total Students',
                                value: controller.totalStudents.value.toCompact(),
                              ),
                              KpiCard(
                                icon: Icons.school_outlined,
                                iconColor: AppColors.secondary,
                                iconBgColor: AppColors.successContainer,
                                trendValue: '5%',
                                trendPositive: true,
                                label: 'Active Now',
                                value: controller.activeNow.value.toCompact(),
                              ),
                              KpiCard(
                                icon: Icons.fact_check_outlined,
                                iconColor: AppColors.error,
                                iconBgColor: AppColors.warningContainer,
                                trendValue: '2%',
                                trendPositive: false,
                                label: 'Attendance',
                                value: '${controller.attendanceRate.value.toStringAsFixed(1)}%',
                              ),
                              KpiCard(
                                icon: Icons.payments_outlined,
                                iconColor: AppColors.primary,
                                iconBgColor: AppColors.surfaceDim,
                                trendValue: '8%',
                                trendPositive: true,
                                label: 'Fee Collection',
                                value: '\$${controller.feeCollection.value.toStringAsFixed(1)}k',
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(width: 16.0),
                    const Expanded(
                      flex: 4,
                      child: AiInsightsCard(),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                
                // Bento grid row 2: Chart + Upcoming Classes
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: SizedBox(
                        height: 400.0,
                        child: Obx(() => MonthlyIncomeChart(
                              incomeData: controller.monthlyIncomeData,
                            )),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 4,
                      child: Obx(() => UpcomingClassesCard(
                            classes: controller.upcomingClasses,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                
                // Bento grid row 3: Recent Activities
                Obx(() => RecentActivitiesCard(
                      activities: controller.recentActivities,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateTime.now().formatted(format: 'EEEE, MMMM dd, yyyy'),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          '${Helpers.getGreeting()}, Sarah!',
          style: AppTypography.displayLargeMobile.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildGreetingHeader(),
        Row(
          children: [
            const SizedBox(
              width: 250.0,
              child: SearchField(hint: 'Search students, classes...'),
            ),
            const SizedBox(width: 16.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.surfaceContainerLowDark 
                    : AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
                    onPressed: () => Get.toNamed(AppRoutes.notifications),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
