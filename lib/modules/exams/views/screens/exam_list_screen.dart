import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/exam_model.dart';
import 'package:taleem/modules/exams/controllers/exam_controller.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/search_field.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final ExamController controller = Get.find<ExamController>();
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

  Color _statusColor(ExamStatus status) {
    switch (status) {
      case ExamStatus.scheduled:
        return AppColors.primary;
      case ExamStatus.ongoing:
        return Colors.orange;
      case ExamStatus.completed:
        return Colors.green;
      case ExamStatus.cancelled:
        return AppColors.error;
    }
  }

  void _showFilterBottomSheet() {
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
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text('Status', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<ExamStatus>(
              value: controller.selectedStatus.value,
              items: ExamStatus.values.map((s) {
                return DropdownMenuItem<ExamStatus>(value: s, child: Text(s.name.capitalizeFirst ?? s.name));
              }).toList(),
              onChanged: (val) => controller.selectedStatus.value = val,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16.0)),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                controller.loadItems(refresh: true);
                Get.back();
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Obx(() => LoadingOverlay(
        isLoading: controller.isLoading.value && controller.items.isEmpty,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: SearchField(
                      hint: 'Search exams...',
                      onChanged: (val) => controller.searchQuery.value = val,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.examForm),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12.0),
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.add_rounded, size: 24.0),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  Text('Sort by: ', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(width: 8.0),
                  ActionChip(
                    label: const Text('Date'),
                    onPressed: () => controller.updateSorting('date', false),
                    backgroundColor: controller.sortByField.value == 'date'
                        ? AppColors.primaryContainer.withValues(alpha: 0.2)
                        : null,
                  ),
                  const SizedBox(width: 8.0),
                  ActionChip(
                    label: const Text('Name'),
                    onPressed: () => controller.updateSorting('name', false),
                    backgroundColor: controller.sortByField.value == 'name'
                        ? AppColors.primaryContainer.withValues(alpha: 0.2)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: controller.items.isEmpty && !controller.isLoading.value
                  ? const EmptyState(
                      icon: Icons.quiz_rounded,
                      title: 'No Exams Found',
                      subtitle: 'Try adjusting your filters or schedule a new exam.',
                    )
                  : RefreshIndicator(
                      onRefresh: () => controller.loadItems(refresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: controller.items.length + (controller.isMoreLoading.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final exam = controller.items[index];
                          final color = _statusColor(exam.status);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              onTap: () => Get.toNamed(AppRoutes.examForm, arguments: exam),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exam.name,
                                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      StatusChip(
                                        label: exam.status.name,
                                        color: color,
                                        textColor: color,
                                        size: StatusChipSize.small,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 14.0, color: AppColors.outline),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        exam.date.toString().substring(0, 10),
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Icon(Icons.timer_rounded, size: 14.0, color: AppColors.outline),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        '${exam.duration} min',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Icon(Icons.score_rounded, size: 14.0, color: AppColors.outline),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        '${exam.totalMarks.toInt()} marks',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.examForm),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
