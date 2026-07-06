import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/exam_model.dart';
import 'package:taleem/modules/exams/controllers/exam_controller.dart';
import 'package:taleem/shared/widgets/confirm_dialog.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class ExamDetailScreen extends StatefulWidget {
  const ExamDetailScreen({super.key});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  final ExamController controller = Get.find<ExamController>();
  bool _isFormMode = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is ExamModel) {
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
      title: 'Delete Exam',
      message: 'Are you sure you want to delete "${controller.item.value?.name ?? "this exam"}"?',
      isDestructive: true,
    );
    if (confirmed && controller.item.value != null) {
      await controller.deleteItem(controller.item.value!.id);
      Get.back();
    }
  }

  Future<void> _pickExamDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.examDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.selectExamDate(picked);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFormMode ? (controller.isEditing.value ? 'Edit Exam' : 'New Exam') : 'Exam Details'),
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
    final exam = controller.item.value;
    if (exam == null) {
      return const Center(child: Text('Exam not found'));
    }

    final color = _statusColor(exam.status);

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
                      child: Text(exam.name, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    StatusChip(label: exam.status.name, color: color, textColor: color),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exam Info', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0)),
                const SizedBox(height: 12.0),
                _infoRow('Date', exam.date.toString().substring(0, 10)),
                const SizedBox(height: 8.0),
                _infoRow('Duration', '${exam.duration} minutes'),
                const SizedBox(height: 8.0),
                _infoRow('Total Marks', exam.totalMarks.toString()),
                const SizedBox(height: 8.0),
                _infoRow('Batch ID', exam.batchId),
                const SizedBox(height: 8.0),
                _infoRow('Subject ID', exam.subjectId),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Results', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0)),
                    Text(
                      'Avg: ${exam.averageMarks.toStringAsFixed(1)}',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                _infoRow('Pass %', '${exam.passPercentage.toStringAsFixed(1)}%'),
                const SizedBox(height: 8.0),
                Text('${exam.results.length} student(s)', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
              ],
            ),
          ),
          if (exam.results.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Results Table', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  const SizedBox(height: 12.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student ID')),
                        DataColumn(label: Text('Marks')),
                        DataColumn(label: Text('Grade')),
                        DataColumn(label: Text('Remarks')),
                      ],
                      rows: exam.results.map((r) {
                        return DataRow(cells: [
                          DataCell(Text(r.studentId)),
                          DataCell(Text(r.marksObtained.toString())),
                          DataCell(Text(r.grade ?? '-')),
                          DataCell(Text(r.remarks ?? '-')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                    controller: controller.nameController,
                    decoration: const InputDecoration(labelText: 'Exam Name *'),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Exam Date',
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: controller.examDate.value.toString().substring(0, 10),
                    ),
                    onTap: _pickExamDate,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                    keyboardType: TextInputType.number,
                    initialValue: controller.duration.value.toString(),
                    onChanged: (val) => controller.duration.value = int.tryParse(val) ?? 60,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Total Marks'),
                    keyboardType: TextInputType.number,
                    initialValue: controller.totalMarks.value.toInt().toString(),
                    onChanged: (val) => controller.totalMarks.value = double.tryParse(val) ?? 100.0,
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
                  DropdownButtonFormField<ExamStatus>(
                    value: controller.formStatus.value,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ExamStatus.values.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst ?? s.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.formStatus.value = val;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: controller.saveItem,
              child: Text(controller.isEditing.value ? 'Save Changes' : 'Create Exam'),
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
