import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/teacher_model.dart';
import 'package:taleem/modules/teachers/controllers/teacher_controller.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/search_field.dart';
import 'package:taleem/shared/widgets/shimmer_loading.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final TeacherController controller = Get.find<TeacherController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () { controller.clearFilters(); Get.back(); },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Status', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<TeacherStatus>(
              value: controller.selectedStatus.value,
              items: TeacherStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst ?? s.name))).toList(),
              onChanged: (val) => controller.selectedStatus.value = val,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () { controller.loadItems(refresh: true); Get.back(); },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(TeacherStatus status) {
    switch (status) {
      case TeacherStatus.active: return Colors.green;
      case TeacherStatus.inactive: return Colors.red;
      case TeacherStatus.onLeave: return Colors.orange;
    }
  }

  Color _statusTextColor(TeacherStatus status) {
    switch (status) {
      case TeacherStatus.active: return Colors.green;
      case TeacherStatus.inactive: return Colors.red;
      case TeacherStatus.onLeave: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: (_) => _buildContent(context),
        desktop: (_) => _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return _buildShimmerList();
      }

      if (controller.error.isNotEmpty && controller.items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.error.value, style: AppTypography.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadItems(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Search teachers...',
                    onChanged: (val) => controller.searchQuery.value = val,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.teacherForm),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.add_rounded, size: 24),
                ),
              ],
            ),
          ),
          Expanded(
            child: controller.items.isEmpty
                ? const EmptyState(
                    icon: Icons.person_off_rounded,
                    title: 'No Teachers Found',
                    subtitle: 'Add a teacher to get started.',
                  )
                : RefreshIndicator(
                    onRefresh: () => controller.loadItems(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.items.length + (controller.isMoreLoading.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final teacher = controller.items[index];
                        return _buildTeacherCard(teacher);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: () => Get.toNamed(AppRoutes.teacherDetail, parameters: {'id': teacher.id}),
        child: Row(
          children: [
            AvatarWidget(
              imageUrl: teacher.photoUrl,
              name: teacher.name,
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.name,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  if (teacher.qualification != null)
                    Text(
                      teacher.qualification!,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusChip(
                        label: teacher.status.name,
                        color: _statusColor(teacher.status),
                        textColor: _statusTextColor(teacher.status),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.book_rounded, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${teacher.subjectIds.length} subjects',
                        style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const ShimmerLoading(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading(width: 150, height: 14),
                    const SizedBox(height: 8),
                    const ShimmerLoading(width: 100, height: 12),
                    const SizedBox(height: 6),
                    const ShimmerLoading(width: 80, height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
