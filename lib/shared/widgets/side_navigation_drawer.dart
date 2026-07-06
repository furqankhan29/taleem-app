import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';

class SideNavigationDrawer extends StatelessWidget {
  final String currentRoute;

  const SideNavigationDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 320.0,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerDark : AppColors.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.outlineVariantDark : AppColors.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2.0,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCrTpxYgApPfh79vQAfOAvID7WsrmCAT8uPVVJDtEfm1dNLS0Xo1RW-9cxeHHdPgrfNOPVIu3vAC0K76oAOOMivIprUIr21Va185OawVewzl6MVSYH_zEPTJY46enBUGi6quL_7EklPY8Q9tSFZzvtejqcdcSmGvvmvJYZmHd9rkeQoRSVQ611Xp4wuP1u9bHmw6renllfu-gIcy1WHZEoYdlzCfRq8zUDu1kxph3fSJOmIOEiXrB712bosMtvdMl-krnknWO_dqm_7',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin User',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        Text(
                          'Taleem Premium',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildNavItem(
                    label: 'Dashboard',
                    icon: Symbols.dashboard,
                    route: AppRoutes.dashboard,
                  ),
                  _buildNavItem(
                    label: 'Students',
                    icon: Symbols.group,
                    route: AppRoutes.studentList,
                  ),
                  _buildNavItem(
                    label: 'Attendance',
                    icon: Symbols.fact_check,
                    route: AppRoutes.attendance,
                  ),
                  _buildNavItem(
                    label: 'AI Assistant',
                    icon: Symbols.smart_toy,
                    route: AppRoutes.aiAssistant,
                  ),
                  _buildNavItem(
                    label: 'Fee Management',
                    icon: Symbols.payments,
                    route: AppRoutes.feeManagement,
                  ),
                  _buildNavItem(
                    label: 'WhatsApp Reminders',
                    icon: Symbols.forum,
                    route: AppRoutes.whatsappReminders,
                  ),
                  _buildNavItem(
                    label: 'Reports',
                    icon: Symbols.assessment,
                    route: AppRoutes.reports,
                  ),
                  _buildNavItem(
                    label: 'Notifications',
                    icon: Symbols.notifications,
                    route: AppRoutes.notifications,
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: AppColors.outlineVariant, height: 1.0),
                  ),
                  
                  _buildNavItem(
                    label: 'Teachers',
                    icon: Symbols.supervisor_account,
                    route: AppRoutes.teacherList,
                  ),
                  _buildNavItem(
                    label: 'Parents',
                    icon: Symbols.family_restroom,
                    route: AppRoutes.parentList,
                  ),
                  _buildNavItem(
                    label: 'Batches',
                    icon: Symbols.school,
                    route: AppRoutes.batchList,
                  ),
                  _buildNavItem(
                    label: 'Subjects',
                    icon: Symbols.menu_book,
                    route: AppRoutes.subjectList,
                  ),
                  _buildNavItem(
                    label: 'Homework',
                    icon: Symbols.assignment,
                    route: AppRoutes.homeworkList,
                  ),
                  _buildNavItem(
                    label: 'Exams',
                    icon: Symbols.quiz,
                    route: AppRoutes.examList,
                  ),
                  _buildNavItem(
                    label: 'Timetable',
                    icon: Symbols.calendar_view_week,
                    route: AppRoutes.timetable,
                  ),
                  _buildNavItem(
                    label: 'Calendar',
                    icon: Symbols.calendar_today,
                    route: AppRoutes.calendar,
                  ),
                  _buildNavItem(
                    label: 'Activity Logs',
                    icon: Symbols.history,
                    route: AppRoutes.activityLogs,
                  ),
                ],
              ),
            ),
            
            // Footer Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: AppColors.outlineVariant, height: 1.0),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildNavItem(
                    label: 'Settings',
                    icon: Symbols.settings,
                    route: AppRoutes.settings,
                  ),
                  _buildNavItem(
                    label: 'Logout',
                    icon: Symbols.logout,
                    route: AppRoutes.login,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'v1.0.4',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.outline.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required String route,
    Color? color,
  }) {
    final isActive = currentRoute == route;
    final isLogout = label == 'Logout';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          if (isLogout) {
            // Perform logout action, then go to login
            Get.offAllNamed(AppRoutes.login);
          } else if (!isActive) {
            Get.toNamed(route);
          }
        },
        borderRadius: BorderRadius.circular(AppRadius.regular),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.secondaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.regular),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color ?? (isActive ? AppColors.secondary : AppColors.onSurfaceVariant),
                fill: isActive ? 1.0 : 0.0,
                size: 24.0,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: color ?? (isActive ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
