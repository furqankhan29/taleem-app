import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/extensions.dart';
import 'package:taleem/data/models/parent_model.dart';
import 'package:taleem/modules/students/controllers/student_detail_controller.dart';
import 'package:taleem/modules/students/views/widgets/activity_timeline.dart';
import 'package:taleem/modules/students/views/widgets/academic_trajectory_chart.dart';
import 'package:taleem/modules/students/views/widgets/ai_performance_card.dart';
import 'package:taleem/modules/students/views/widgets/student_id_card.dart';
import 'package:taleem/modules/students/views/widgets/student_stat_cards.dart';
import 'package:taleem/modules/attendance/views/widgets/attendance_heatmap_widget.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/side_navigation_drawer.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/shared/widgets/status_chip.dart';
import 'package:taleem/core/utils/formatters.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final StudentDetailController controller = Get.find<StudentDetailController>();
  late final String studentId;

  @override
  void initState() {
    super.initState();
    // Get student ID from route parameters
    studentId = Get.parameters['id'] ?? '';
    controller.fetchStudentDetails(studentId);
  }

  void _launchCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _launchWhatsApp(String phone) async {
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s-()]+'), '');
    final url = Uri.parse('https://wa.me/$cleanedPhone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.isDesktop ? null : AppBar(
        title: const Text('Student Profile'),
        actions: [
          Obx(() => controller.student.value != null
              ? IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                  onPressed: () async {
                    final result = await Get.toNamed(AppRoutes.studentForm, arguments: controller.student.value);
                    if (result != null) {
                      controller.fetchStudentDetails(studentId);
                    }
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value && controller.student.value == null,
            child: ResponsiveLayout(
              mobile: (context) => _buildMobileLayout(context),
              desktop: (context) => _buildDesktopLayout(context),
            ),
          )),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final s = controller.student.value;
    final p = controller.parent.value;

    if (s == null) {
      return const Center(child: Text('Student not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Glass ID Card
          StudentIdCard(student: s),
          const SizedBox(height: 16.0),

          // Primary Contact Card
          _buildPrimaryContactCard(p),
          const SizedBox(height: 16.0),

          // Tab Options
          _buildProfileTabs(context),
          const SizedBox(height: 16.0),

          // Tab Content Panel
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final s = controller.student.value;
    final p = controller.parent.value;

    if (s == null) {
      return const Center(child: Text('Student not found'));
    }

    return Row(
      children: [
        const SideNavigationDrawer(currentRoute: AppRoutes.studentList),
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
                      'Student Profile - ${s.name}',
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Get.toNamed(AppRoutes.studentForm, arguments: s);
                        if (result != null) {
                          controller.fetchStudentDetails(studentId);
                        }
                      },
                      icon: const Icon(Icons.edit_rounded, size: 16.0),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: Profile card + Contacts
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          StudentIdCard(student: s),
                          const SizedBox(height: 16.0),
                          _buildPrimaryContactCard(p),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),

                    // Right column: Tabs content (Bento Grid)
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          _buildProfileTabs(context),
                          const SizedBox(height: 16.0),
                          _buildTabContent(),
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

  Widget _buildPrimaryContactCard(ParentModel? p) {
    final name = p?.name ?? 'Guardian (Pending)';
    final relation = p?.relation ?? 'Parent';
    final phone = p?.phone ?? 'No contact number';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contacts_outlined, color: AppColors.primary, size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                'Primary Contact',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: const BoxDecoration(color: AppColors.primaryFixed, shape: BoxShape.circle),
                child: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      relation,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            phone,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
          ),
          if (p != null) ...[
            const SizedBox(height: 16.0),
            Row(
              children: [
                if (p.phone != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchCall(p.phone!),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: const Icon(Icons.phone_rounded, size: 16.0),
                      label: const Text('Call'),
                    ),
                  ),
                if (p.whatsappNumber != null || p.phone != null) ...[
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchWhatsApp(p.whatsappNumber ?? p.phone!),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                      icon: const Icon(Icons.chat_rounded, size: 16.0),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
                if (p.email != null) ...[
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.regular),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mail_outline_rounded, color: AppColors.onSurfaceVariant),
                      onPressed: () => _launchEmail(p.email!),
                    ),
                  ),
                ],
              ],
            )
          ],
        ],
      ),
    );
  }

  Widget _buildProfileTabs(BuildContext context) {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surfaceContainerLowDark 
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.regular),
      ),
      padding: const EdgeInsets.all(4.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTabItem(0, 'Overview'),
          _buildTabItem(1, 'Attendance Heatmap'),
          _buildTabItem(2, 'Academics'),
          _buildTabItem(3, 'Fees'),
          _buildTabItem(4, 'Documents'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isActive = controller.activeTab.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.regular - 2),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (controller.activeTab.value) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return AttendanceHeatmapWidget(
          heatmapData: controller.attendanceHeatmap,
          month: DateTime.now(),
        );
      case 2:
        return _buildPlaceholderTab('Academic Performance & Submissions');
      case 3:
        return _buildFeeTab();
      case 4:
        return _buildPlaceholderTab('Uploaded Documents & Files');
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildFeeTab() {
    return Obx(() => controller.studentFees.isEmpty
        ? _buildPlaceholderTab('No Invoices Recorded')
        : Column(
            children: controller.studentFees.map((f) {
              final isPaid = f.status == FeePaymentStatus.paid;
              final chipColor = isPaid
                  ? Colors.green
                  : (f.status == FeePaymentStatus.partial ? Colors.orange : Colors.red);
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
                            Text(
                              'Category: ${f.type.name.capitalizeFirst} | Term: ${f.term ?? "Monthly"}',
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Due Date: ${Formatters.formatDate(f.dueDate)}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.toCurrency(f.amount),
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6.0),
                          StatusChip(
                            label: f.status.name,
                            color: chipColor,
                            textColor: chipColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ));
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AiPerformanceCard(insight: controller.aiPerformanceInsight.value),
        const SizedBox(height: 16.0),
        
        SizedBox(
          height: 350.0,
          child: AcademicTrajectoryChart(spotsData: controller.academicTrajectory),
        ),
        const SizedBox(height: 16.0),

        StudentStatCards(
          rank: controller.studentStats['classRank'] ?? 'N/A',
          demerits: controller.studentStats['demerits'] ?? '0',
          feeStatus: controller.studentStats['feeStatus'] ?? 'Pending',
          awards: controller.studentStats['awards'] ?? '0',
        ),
        const SizedBox(height: 16.0),

        ActivityTimeline(logs: controller.activityLogs),
      ],
    );
  }

  Widget _buildPlaceholderTab(String label) {
    return Container(
      height: 200.0,
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xCCFFFFFF), width: 1.0),
      ),
      child: Center(
        child: Text(
          '$label Tab\n(Will be completed in subsequent phases)',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.outline),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
