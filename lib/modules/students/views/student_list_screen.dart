import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/modules/students/controllers/student_list_controller.dart';
import 'package:taleem/modules/students/views/widgets/student_card.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/search_field.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final StudentListController controller = Get.find<StudentListController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreStudents();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
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
                Text(
                  'Filters',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
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
            
            // Grade Filter
            Text('Grade Level', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: controller.selectedGrade.value,
              items: ['Grade 10', 'Grade 11', 'Grade 12'].map((g) {
                return DropdownMenuItem<String>(
                  value: g,
                  child: Text(g),
                );
              }).toList(),
              onChanged: (val) => controller.selectedGrade.value = val,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16.0)),
            ),
            const SizedBox(height: 16.0),

            // Fee Status Filter
            Text('Fee Status', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<FeeStatus>(
              value: controller.selectedFeeStatus.value,
              items: FeeStatus.values.map((fs) {
                return DropdownMenuItem<FeeStatus>(
                  value: fs,
                  child: Text(fs.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => controller.selectedFeeStatus.value = val,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16.0)),
            ),
            const SizedBox(height: 24.0),

            ElevatedButton(
              onPressed: () {
                controller.loadStudents(refresh: true);
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
        title: const Text('Student Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value && controller.students.isEmpty,
            child: Column(
              children: [
                // Search field + Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SearchField(
                          hint: 'Search students...',
                          onChanged: (val) => controller.searchQuery.value = val,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.studentForm),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(12.0),
                          shape: const CircleBorder(),
                        ),
                        child: const Icon(Icons.add_rounded, size: 24.0),
                      ),
                    ],
                  ),
                ),
                
                // Sorting chips row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        'Sort by: ',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
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
                        label: const Text('Date Joined'),
                        onPressed: () => controller.updateSorting('createdAt', true),
                        backgroundColor: controller.sortByField.value == 'createdAt'
                            ? AppColors.primaryContainer.withValues(alpha: 0.2)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),

                // Student lists view
                Expanded(
                  child: controller.students.isEmpty && !controller.isLoading.value
                      ? const EmptyState(
                          icon: Symbols.group,
                          title: 'No Students Found',
                          subtitle: 'Try adjusting your filters or register a new student.',
                        )
                      : RefreshIndicator(
                          onRefresh: () => controller.loadStudents(refresh: true),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: controller.students.length + (controller.isMoreLoading.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == controller.students.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final student = controller.students[index];
                              return StudentCard(
                                student: student,
                                onDelete: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Delete Student'),
                                      content: Text('Are you sure you want to delete ${student.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.back();
                                            controller.deleteStudent(student.id);
                                          },
                                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          )),
    );
  }
}
