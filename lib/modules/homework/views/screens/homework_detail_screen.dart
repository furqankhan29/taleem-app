import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/homework_model.dart';
import 'package:taleem/modules/homework/controllers/homework_controller.dart';
import 'package:taleem/shared/widgets/confirm_dialog.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class HomeworkDetailScreen extends StatefulWidget {
  const HomeworkDetailScreen({super.key});

  @override
  State<HomeworkDetailScreen> createState() => _HomeworkDetailScreenState();
}

class _HomeworkDetailScreenState extends State<HomeworkDetailScreen> {
  final HomeworkController controller = Get.find<HomeworkController>();
  bool _isFormMode = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is HomeworkModel) {
      controller.item.value = args;
      controller.populateForm(args);
    } else {
      _isFormMode = true;
      controller.populateForm(null);
    }
  }

  @override
  void dispose() {
    controller.item.value = null;
    super.dispose();
  }

  void _toggleFormMode() {
    setState(() {
      _isFormMode = !_isFormMode;
      if (!_isFormMode && controller.item.value != null) {
        controller.populateForm(controller.item.value);
      }
    });
  }

  Future<void> _handleDelete() async {
    final confirmed = await ConfirmDialog.show(
      title: 'Delete Homework',
      message: 'Are you sure you want to delete "${controller.item.value?.title ?? "this homework"}"?',
      isDestructive: true,
    );
    if (confirmed && controller.item.value != null) {
      await controller.deleteItem(controller.item.value!.id);
      Get.back();
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.dueDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.selectDueDate(picked);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFormMode ? (controller.isEditing.value ? 'Edit Homework' : 'New Homework') : 'Homework Details'),
        actions: [
          if (!_isFormMode)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _toggleFormMode();
                if (value == 'delete') _handleDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      body: Obx(() => LoadingOverlay(
        isLoading: controller.isSaving.value,
        child: _isFormMode ? _buildForm() : _buildDetails(),
      )),
    );
  }

  Widget _buildDetails() {
    final hw = controller.item.value;
    if (hw == null) {
      return const Center(child: Text('Homework not found'));
    }

    final color = _statusColor(hw.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(hw.title, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    StatusChip(
                      label: hw.isOverdue ? 'OVERDUE' : hw.status.name,
                      color: color,
                      textColor: color,
                    ),
                  ],
                ),
                if (hw.description != null && hw.description!.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  Text('Description', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  const SizedBox(height: 4.0),
                  Text(hw.description!, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Details', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0)),
                const SizedBox(height: 12.0),
                _infoRow('Batch ID', hw.batchId),
                const SizedBox(height: 8.0),
                _infoRow('Subject ID', hw.subjectId),
                const SizedBox(height: 8.0),
                _infoRow('Teacher ID', hw.teacherId),
                const SizedBox(height: 8.0),
                _infoRow('Due Date', hw.dueDate.toString().substring(0, 10)),
                const SizedBox(height: 8.0),
                _infoRow('Status', hw.status.name.capitalizeFirst ?? hw.status.name),
                const SizedBox(height: 8.0),
                _infoRow('Attachments', '${hw.attachments.length} file(s)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.titleController,
                    decoration: const InputDecoration(labelText: 'Title *'),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: controller.descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: controller.dueDate.value.toString().substring(0, 10),
                    ),
                    onTap: _pickDueDate,
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: controller.formBatchId.value.isNotEmpty ? controller.formBatchId.value : null,
                    decoration: const InputDecoration(labelText: 'Batch *'),
                    items: const [
                      DropdownMenuItem(value: 'batch_1', child: Text('Batch A')),
                      DropdownMenuItem(value: 'batch_2', child: Text('Batch B')),
                    ],
                    onChanged: (val) => controller.formBatchId.value = val ?? '',
                    validator: (val) => (val == null || val.isEmpty) ? 'Batch is required' : null,
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: controller.formSubjectId.value.isNotEmpty ? controller.formSubjectId.value : null,
                    decoration: const InputDecoration(labelText: 'Subject *'),
                    items: const [
                      DropdownMenuItem(value: 'subj_1', child: Text('Mathematics')),
                      DropdownMenuItem(value: 'subj_2', child: Text('Physics')),
                    ],
                    onChanged: (val) => controller.formSubjectId.value = val ?? '',
                    validator: (val) => (val == null || val.isEmpty) ? 'Subject is required' : null,
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<HomeworkStatus>(
                    value: controller.formStatus.value,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: HomeworkStatus.values.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst ?? s.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.formStatus.value = val;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attachments', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.upload_file_rounded, size: 32.0, color: AppColors.outline),
                          const SizedBox(height: 8.0),
                          Text('Attachments placeholder', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: controller.saveItem,
              child: Text(controller.isEditing.value ? 'Save Changes' : 'Create Homework'),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        Flexible(
          child: Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
