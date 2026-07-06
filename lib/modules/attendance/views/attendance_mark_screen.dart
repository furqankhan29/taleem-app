import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/data/models/attendance_model.dart';
import 'package:taleem/modules/attendance/controllers/attendance_mark_controller.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';

class AttendanceMarkScreen extends GetView<AttendanceMarkController> {
  const AttendanceMarkScreen({super.key});

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.selectedDate.value = picked;
      controller.loadStudentsAndAttendance();
    }
  }

  void _showNoteDialog(BuildContext context, String studentId, String studentName) {
    final textController = TextEditingController(text: controller.noteMap[studentId] ?? '');
    
    Get.dialog(
      AlertDialog(
        title: Text('Note for $studentName'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Enter reason for absence/leave...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.updateNote(studentId, textController.text.trim());
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value || controller.isSaving.value,
            child: Column(
              children: [
                // Top controls (Batch choice, date selection)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Date Selector Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today_rounded, size: 16.0),
                          label: Text(Formatters.formatDate(controller.selectedDate.value)),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      
                      // Batch Dropdown Selection
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: controller.selectedBatchId.value,
                          items: controller.batches.map((b) {
                            return DropdownMenuItem<String>(
                              value: b['id']!,
                              child: Text(b['name']!, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedBatchId.value = val;
                              controller.loadStudentsAndAttendance();
                            }
                          },
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12.0)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bulk action tools (Mark All Present/Absent)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Class Size: ${controller.students.length}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.outline, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: controller.markAllPresent,
                            icon: const Icon(Icons.done_all_rounded, size: 16.0),
                            label: const Text('All Present'),
                          ),
                          const SizedBox(width: 8.0),
                          TextButton.icon(
                            onPressed: controller.markAllAbsent,
                            icon: const Icon(Icons.close_rounded, size: 16.0),
                            label: const Text('All Absent'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // List of students to toggle status
                Expanded(
                  child: controller.students.isEmpty && !controller.isLoading.value
                      ? const EmptyState(
                          icon: Icons.person_off_rounded,
                          title: 'No Students in Batch',
                          subtitle: 'Add students to this batch in the Student Directory first.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: controller.students.length,
                          itemBuilder: (context, index) {
                            final student = controller.students[index];
                            final currentStatus = controller.attendanceMap[student.id] ?? AttendanceStatus.present;
                            final hasNote = controller.noteMap.containsKey(student.id) && controller.noteMap[student.id]!.isNotEmpty;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    AvatarWidget(
                                      imageUrl: student.photoUrl,
                                      name: student.name,
                                      size: 40.0,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'ID: ${student.studentId}',
                                            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    
                                    // Status Toggles
                                    _buildStatusToggles(student.id, currentStatus),
                                    const SizedBox(width: 8.0),
                                    
                                    // Note Button
                                    IconButton(
                                      icon: Icon(
                                        hasNote ? Icons.note_rounded : Icons.note_add_outlined,
                                        color: hasNote ? AppColors.primary : AppColors.outline,
                                        size: 20.0,
                                      ),
                                      onPressed: () => _showNoteDialog(context, student.id, student.name),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Save Action Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: controller.saveAttendance,
                    child: const Text('Save Attendance Log'),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildStatusToggles(String studentId, AttendanceStatus currentStatus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleItem(studentId, AttendanceStatus.present, 'P', currentStatus, AppColors.primary),
        const SizedBox(width: 4.0),
        _buildToggleItem(studentId, AttendanceStatus.absent, 'A', currentStatus, AppColors.tertiary),
        const SizedBox(width: 4.0),
        _buildToggleItem(studentId, AttendanceStatus.late, 'L', currentStatus, AppColors.secondary),
        const SizedBox(width: 4.0),
        _buildToggleItem(studentId, AttendanceStatus.leave, 'LV', currentStatus, AppColors.outline),
      ],
    );
  }

  Widget _buildToggleItem(
    String studentId,
    AttendanceStatus itemStatus,
    String initials,
    AttendanceStatus activeStatus,
    Color activeColor,
  ) {
    final isActive = activeStatus == itemStatus;
    
    return GestureDetector(
      onTap: () => controller.updateStatus(studentId, itemStatus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.outlineVariant,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
          ),
        ),
      ),
    );
  }
}
