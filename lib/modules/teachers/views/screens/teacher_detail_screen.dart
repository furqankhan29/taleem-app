import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/teacher_model.dart';
import 'package:taleem/data/repositories/teacher_repository.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/confirm_dialog.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class TeacherDetailScreen extends StatefulWidget {
  const TeacherDetailScreen({super.key});

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  final TeacherRepository _repository = Get.find<TeacherRepository>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController employeeIdCtrl = TextEditingController();
  final TextEditingController qualificationCtrl = TextEditingController();
  final TextEditingController experienceCtrl = TextEditingController();
  final TextEditingController specializationCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;
  final Rxn<TeacherModel> teacher = Rxn<TeacherModel>();
  final Rxn<TeacherStatus> selectedStatus = Rxn<TeacherStatus>();

  late String teacherId;

  @override
  void initState() {
    super.initState();
    teacherId = Get.parameters['id'] ?? '';
    final argument = Get.arguments;
    if (argument is TeacherModel) {
      teacher.value = argument;
      _populateFields(argument);
      isLoading.value = false;
    } else if (teacherId.isNotEmpty) {
      _loadTeacher();
    } else {
      isEditing.value = true;
      isLoading.value = false;
    }
  }

  Future<void> _loadTeacher() async {
    try {
      final model = await _repository.getById(teacherId);
      if (model != null) {
        teacher.value = model;
        _populateFields(model);
      }
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  void _populateFields(TeacherModel model) {
    nameCtrl.text = model.name;
    emailCtrl.text = model.email;
    phoneCtrl.text = model.phone ?? '';
    employeeIdCtrl.text = model.employeeId ?? '';
    qualificationCtrl.text = model.qualification ?? '';
    experienceCtrl.text = model.experience ?? '';
    specializationCtrl.text = model.specialization ?? '';
    selectedStatus.value = model.status;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    employeeIdCtrl.dispose();
    qualificationCtrl.dispose();
    experienceCtrl.dispose();
    specializationCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(TeacherStatus status) {
    switch (status) {
      case TeacherStatus.active: return Colors.green;
      case TeacherStatus.inactive: return Colors.red;
      case TeacherStatus.onLeave: return Colors.orange;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    isSaving.value = true;
    Helpers.showLoadingDialog(isEditing.value && teacher.value != null ? 'Updating...' : 'Creating...');

    try {
      final model = TeacherModel(
        id: teacher.value?.id ?? Helpers.generateUniqueId(),
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
        employeeId: employeeIdCtrl.text.trim().isNotEmpty ? employeeIdCtrl.text.trim() : null,
        qualification: qualificationCtrl.text.trim().isNotEmpty ? qualificationCtrl.text.trim() : null,
        experience: experienceCtrl.text.trim().isNotEmpty ? experienceCtrl.text.trim() : null,
        specialization: specializationCtrl.text.trim().isNotEmpty ? specializationCtrl.text.trim() : null,
        status: selectedStatus.value ?? TeacherStatus.active,
        subjectIds: teacher.value?.subjectIds ?? [],
        batchIds: teacher.value?.batchIds ?? [],
        createdAt: teacher.value?.createdAt ?? DateTime.now(),
        photoUrl: teacher.value?.photoUrl,
      );

      if (teacher.value != null) {
        await _repository.update(model);
      } else {
        await _repository.create(model);
      }

      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: teacher.value != null ? 'Teacher updated' : 'Teacher created');
      Get.back(result: model);
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Error', message: e.toString(), isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _delete() async {
    if (teacher.value == null) return;
    final confirmed = await ConfirmDialog.show(
      title: 'Delete Teacher',
      message: 'Are you sure you want to delete ${teacher.value!.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed) {
      await _repository.delete(teacher.value!.id);
      Helpers.showSnackbar(title: 'Deleted', message: 'Teacher removed successfully');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing.value && teacher.value != null ? 'Edit Teacher' : teacher.value != null ? 'Teacher Details' : 'Add Teacher'),
        actions: [
          if (teacher.value != null && !isEditing.value)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              onPressed: () => isEditing.value = true,
            ),
          if (teacher.value != null && isEditing.value)
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
    final s = teacher.value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (s != null && !isEditing.value) ...[
              _buildDetailView(s),
            ] else ...[
              _buildEditForm(s),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(s != null ? 'Save Changes' : 'Create Teacher'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(TeacherModel s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AvatarWidget(
            imageUrl: s.photoUrl,
            name: s.name,
            size: 80,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(s.name, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
        ),
        if (s.employeeId != null)
          Center(
            child: Text('ID: ${s.employeeId}', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          ),
        const SizedBox(height: 8),
        Center(child: StatusChip(label: s.status.name, color: _statusColor(s.status), textColor: _statusColor(s.status))),
        const SizedBox(height: 24),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.email_outlined, 'Email', s.email),
              if (s.phone != null) ...[const Divider(), _detailRow(Icons.phone_rounded, 'Phone', s.phone!)],
              if (s.employeeId != null) ...[const Divider(), _detailRow(Icons.badge_rounded, 'Employee ID', s.employeeId!)],
              if (s.qualification != null) ...[const Divider(), _detailRow(Icons.school_rounded, 'Qualification', s.qualification!)],
              if (s.experience != null) ...[const Divider(), _detailRow(Icons.work_history_rounded, 'Experience', s.experience!)],
              if (s.specialization != null) ...[const Divider(), _detailRow(Icons.psychology_rounded, 'Specialization', s.specialization!)],
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assigned Subjects (${s.subjectIds.length})', style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              if (s.subjectIds.isEmpty) ...[const SizedBox(height: 8), Text('No subjects assigned', style: AppTypography.bodySmall)],
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assigned Batches (${s.batchIds.length})', style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              if (s.batchIds.isEmpty) ...[const SizedBox(height: 8), Text('No batches assigned', style: AppTypography.bodySmall)],
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

  Widget _buildEditForm(TeacherModel? s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: employeeIdCtrl,
                decoration: const InputDecoration(labelText: 'Employee ID'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: qualificationCtrl,
                decoration: const InputDecoration(labelText: 'Qualification'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: experienceCtrl,
                decoration: const InputDecoration(labelText: 'Experience'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: specializationCtrl,
                decoration: const InputDecoration(labelText: 'Specialization'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TeacherStatus>(
                value: selectedStatus.value,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TeacherStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst ?? s.name))).toList(),
                onChanged: (v) => selectedStatus.value = v,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
