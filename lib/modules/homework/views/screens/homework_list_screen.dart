import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/homework_model.dart';
import 'package:taleem/modules/homework/controllers/homework_controller.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/search_field.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class HomeworkListScreen extends StatefulWidget {
  const HomeworkListScreen({super.key});

  @override
  State<HomeworkListScreen> createState() => _HomeworkListScreenState();
}

class _HomeworkListScreenState extends State<HomeworkListScreen> {
  final HomeworkController controller = Get.find<HomeworkController>();
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

  Color _statusColor(HomeworkStatus status) {
    switch (status) {
      case HomeworkStatus.active:
        return AppColors.primary;
      case HomeworkStatus.completed:
        return Colors.green;
      case HomeworkStatus.overdue:
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
            DropdownButtonFormField<HomeworkStatus>(
              value: controller.selectedStatus.value,
              items: HomeworkStatus.values.map((s) {
                return DropdownMenuItem<HomeworkStatus>(value: s, child: Text(s.name.capitalizeFirst ?? s.name));
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
        title: const Text('Homework'),
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
                      hint: 'Search homework...',
                      onChanged: (val) => controller.searchQuery.value = val,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.homeworkForm),
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
                    label: const Text('Due Date'),
                    onPressed: () => controller.updateSorting('dueDate', false),
                    backgroundColor: controller.sortByField.value == 'dueDate'
                        ? AppColors.primaryContainer.withValues(alpha: 0.2)
                        : null,
                  ),
                  const SizedBox(width: 8.0),
                  ActionChip(
                    label: const Text('Title'),
                    onPressed: () => controller.updateSorting('title', false),
                    backgroundColor: controller.sortByField.value == 'title'
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
                      icon: Icons.assignment_rounded,
                      title: 'No Homework Found',
                      subtitle: 'Try adjusting your filters or assign new homework.',
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
                          final hw = controller.items[index];
                          final color = _statusColor(hw.status);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              onTap: () => Get.toNamed(AppRoutes.homeworkForm, arguments: hw),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          hw.title,
                                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      StatusChip(
                                        label: hw.isOverdue ? 'OVERDUE' : hw.status.name,
                                        color: color,
                                        textColor: color,
                                        size: StatusChipSize.small,
                                      ),
                                    ],
                                  ),
                                  if (hw.description != null && hw.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4.0),
                                    Text(
                                      hw.description!,
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 14.0, color: AppColors.outline),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        'Due: ${hw.dueDate.toString().substring(0, 10)}',
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
        onPressed: () => Get.toNamed(AppRoutes.homeworkForm),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
