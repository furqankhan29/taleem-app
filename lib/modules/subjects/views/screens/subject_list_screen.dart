import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/modules/subjects/controllers/subject_controller.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/search_field.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final SubjectController controller = Get.find<SubjectController>();
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
            Text('Grade Level', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: controller.selectedGradeLevel.value.isNotEmpty ? controller.selectedGradeLevel.value : null,
              items: ['Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'].map((g) {
                return DropdownMenuItem<String>(value: g, child: Text(g));
              }).toList(),
              onChanged: (val) => controller.selectedGradeLevel.value = val ?? '',
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16.0)),
            ),
            const SizedBox(height: 16.0),
            Text('Category', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: controller.selectedCategory.value.isNotEmpty ? controller.selectedCategory.value : null,
              items: ['Core', 'Elective', 'Practical', 'Language'].map((c) {
                return DropdownMenuItem<String>(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) => controller.selectedCategory.value = val ?? '',
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
        title: const Text('Subjects'),
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
                      hint: 'Search subjects...',
                      onChanged: (val) => controller.searchQuery.value = val,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.subjectForm),
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
                    label: const Text('Name'),
                    onPressed: () => controller.updateSorting('name', false),
                    backgroundColor: controller.sortByField.value == 'name'
                        ? AppColors.primaryContainer.withValues(alpha: 0.2)
                        : null,
                  ),
                  const SizedBox(width: 8.0),
                  ActionChip(
                    label: const Text('Grade Level'),
                    onPressed: () => controller.updateSorting('gradeLevel', false),
                    backgroundColor: controller.sortByField.value == 'gradeLevel'
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
                      icon: Icons.book_rounded,
                      title: 'No Subjects Found',
                      subtitle: 'Try adjusting your filters or add a new subject.',
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
                          final subject = controller.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              onTap: () => Get.toNamed(AppRoutes.subjectForm, arguments: subject),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          subject.name,
                                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (subject.code != null)
                                        Text(
                                          subject.code!,
                                          style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                                        ),
                                    ],
                                  ),
                                  if (subject.description != null && subject.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4.0),
                                    Text(
                                      subject.description!,
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      if (subject.gradeLevel != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            subject.gradeLevel!,
                                            style: AppTypography.labelCaps.copyWith(fontSize: 10.0, color: AppColors.primary),
                                          ),
                                        ),
                                      if (subject.category != null) ...[
                                        const SizedBox(width: 8.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            subject.category!,
                                            style: AppTypography.labelCaps.copyWith(fontSize: 10.0, color: AppColors.secondary),
                                          ),
                                        ),
                                      ],
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
        onPressed: () => Get.toNamed(AppRoutes.subjectForm),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
