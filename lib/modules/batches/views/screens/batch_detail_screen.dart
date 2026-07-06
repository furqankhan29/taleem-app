import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/batch_model.dart';
import 'package:taleem/data/repositories/batch_repository.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/confirm_dialog.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class BatchDetailScreen extends StatefulWidget {
  const BatchDetailScreen({super.key});

  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  final BatchRepository _repository = Get.find<BatchRepository>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController codeCtrl = TextEditingController();
  final TextEditingController startTimeCtrl = TextEditingController();
  final TextEditingController endTimeCtrl = TextEditingController();
  final TextEditingController roomCtrl = TextEditingController();
  final TextEditingController maxCapacityCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;
  final Rxn<BatchModel> batch = Rxn<BatchModel>();
  final Rx<BatchSchedule> selectedSchedule = BatchSchedule.morning.obs;
  final Rx<BatchStatus> selectedStatus = BatchStatus.active.obs;
  final RxList<String> selectedDays = <String>[].obs;
  final Rxn<String> selectedTeacherId = Rxn<String>();

  static const List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;
    if (argument is BatchModel) {
      batch.value = argument;
      _populateFields(argument);
      isLoading.value = false;
    } else {
      isEditing.value = true;
      isLoading.value = false;
    }
  }

  void _populateFields(BatchModel model) {
    nameCtrl.text = model.name;
    codeCtrl.text = model.code;
    startTimeCtrl.text = model.startTime ?? '';
    endTimeCtrl.text = model.endTime ?? '';
    roomCtrl.text = model.room ?? '';
    maxCapacityCtrl.text = model.maxCapacity.toString();
    selectedSchedule.value = model.schedule;
    selectedStatus.value = model.status;
    selectedDays.assignAll(model.days);
    selectedTeacherId.value = model.teacherId;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();
    roomCtrl.dispose();
    maxCapacityCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(BatchStatus status) {
    switch (status) {
      case BatchStatus.active: return Colors.green;
      case BatchStatus.inactive: return Colors.red;
      case BatchStatus.completed: return Colors.blue;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    isSaving.value = true;

    try {
      final model = BatchModel(
        id: batch.value?.id ?? Helpers.generateUniqueId(),
        name: nameCtrl.text.trim(),
        code: codeCtrl.text.trim(),
        schedule: selectedSchedule.value,
        teacherId: selectedTeacherId.value,
        subjectId: batch.value?.subjectId,
        studentIds: batch.value?.studentIds ?? [],
        maxCapacity: int.tryParse(maxCapacityCtrl.text.trim()) ?? 30,
        startTime: startTimeCtrl.text.trim().isNotEmpty ? startTimeCtrl.text.trim() : null,
        endTime: endTimeCtrl.text.trim().isNotEmpty ? endTimeCtrl.text.trim() : null,
        days: selectedDays.toList(),
        room: roomCtrl.text.trim().isNotEmpty ? roomCtrl.text.trim() : null,
        status: selectedStatus.value,
        createdAt: batch.value?.createdAt ?? DateTime.now(),
      );

      if (batch.value != null) {
        await _repository.update(model);
      } else {
        await _repository.create(model);
      }

      Helpers.showSnackbar(title: 'Success', message: batch.value != null ? 'Batch updated' : 'Batch created');
      Get.back(result: model);
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: e.toString(), isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _delete() async {
    if (batch.value == null) return;
    final confirmed = await ConfirmDialog.show(
      title: 'Delete Batch',
      message: 'Are you sure you want to delete ${batch.value!.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed) {
      await _repository.delete(batch.value!.id);
      Helpers.showSnackbar(title: 'Deleted', message: 'Batch removed successfully');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing.value && batch.value != null ? 'Edit Batch' : batch.value != null ? 'Batch Details' : 'Add Batch'),
        actions: [
          if (batch.value != null && !isEditing.value)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              onPressed: () => isEditing.value = true,
            ),
          if (batch.value != null && isEditing.value)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppColors.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ResponsiveLayout(
          mobile: (_) => _buildForm(context),
          desktop: (_) => _buildForm(context),
        );
      }),
    );
  }

  Widget _buildForm(BuildContext context) {
    final b = batch.value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (b != null && !isEditing.value) ...[
              _buildDetailView(b),
            ] else ...[
              _buildEditForm(b),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(b != null ? 'Save Changes' : 'Create Batch'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(BatchModel b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AvatarWidget(
            name: b.name,
            size: 64,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(b.name, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
        ),
        Center(
          child: Text(b.code, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        ),
        const SizedBox(height: 8),
        Center(child: StatusChip(label: b.status.name, color: _statusColor(b.status), textColor: _statusColor(b.status))),
        const SizedBox(height: 24),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.schedule_rounded, 'Schedule', b.schedule.name.capitalizeFirst ?? b.schedule.name),
              if (b.startTime != null || b.endTime != null)
                _detailRow(Icons.access_time_rounded, 'Time', '${b.startTime ?? '--'} - ${b.endTime ?? '--'}'),
              if (b.room != null) _detailRow(Icons.meeting_room_rounded, 'Room', b.room!),
              if (b.days.isNotEmpty) _detailRow(Icons.calendar_view_week_rounded, 'Days', b.days.join(', ')),
              _detailRow(Icons.people_rounded, 'Students', '${b.currentStrength} / ${b.maxCapacity}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (b.studentIds.isNotEmpty)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enrolled Students (${b.studentIds.length})', style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...b.studentIds.map((id) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 18, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(id, style: AppTypography.bodySmall),
                    ],
                  ),
                )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BatchModel? b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Batch Name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Batch Code *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Code is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BatchSchedule>(
                value: selectedSchedule.value,
                decoration: const InputDecoration(labelText: 'Schedule *'),
                items: BatchSchedule.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst ?? s.name))).toList(),
                onChanged: (v) => selectedSchedule.value = v ?? BatchSchedule.morning,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: startTimeCtrl,
                      decoration: const InputDecoration(labelText: 'Start Time (e.g. 08:00)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: endTimeCtrl,
                      decoration: const InputDecoration(labelText: 'End Time (e.g. 10:00)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: roomCtrl,
                decoration: const InputDecoration(labelText: 'Room'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: maxCapacityCtrl,
                decoration: const InputDecoration(labelText: 'Max Capacity *'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Capacity is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BatchStatus>(
                value: selectedStatus.value,
                decoration: const InputDecoration(labelText: 'Status'),
                items: BatchStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst ?? s.name))).toList(),
                onChanged: (v) => selectedStatus.value = v ?? BatchStatus.active,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Days of Week'),
        const SizedBox(height: 12),
        GlassCard(
          child: Obx(() => Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _allDays.map((day) {
              final isSelected = selectedDays.contains(day);
              return ChoiceChip(
                label: Text(day, style: AppTypography.bodySmall),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    selectedDays.add(day);
                  } else {
                    selectedDays.remove(day);
                  }
                },
              );
            }).toList(),
          )),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
