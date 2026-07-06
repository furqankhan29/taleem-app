import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/subject_model.dart';
import 'package:taleem/modules/subjects/controllers/subject_controller.dart';
import 'package:taleem/shared/widgets/confirm_dialog.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';

class SubjectDetailScreen extends StatefulWidget {
  const SubjectDetailScreen({super.key});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final SubjectController controller = Get.find<SubjectController>();
  bool _isFormMode = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is SubjectModel) {
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
      title: 'Delete Subject',
      message: 'Are you sure you want to delete ${controller.item.value?.name ?? "this subject"}?',
      isDestructive: true,
    );
    if (confirmed && controller.item.value != null) {
      await controller.deleteItem(controller.item.value!.id);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFormMode ? (controller.isEditing.value ? 'Edit Subject' : 'New Subject') : 'Subject Details'),
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
    final s = controller.item.value;
    if (s == null) {
      return const Center(child: Text('Subject not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                if (s.code != null) ...[
                  const SizedBox(height: 4.0),
                  Text('Code: ${s.code}', style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                ],
                if (s.description != null && s.description!.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  Text('Description', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  const SizedBox(height: 4.0),
                  Text(s.description!, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Classification', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.0)),
                const SizedBox(height: 12.0),
                _infoRow('Grade Level', s.gradeLevel ?? 'Not specified'),
                const SizedBox(height: 8.0),
                _infoRow('Category', s.category ?? 'Not specified'),
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
                    controller: controller.nameController,
                    decoration: const InputDecoration(labelText: 'Subject Name *'),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: controller.codeController,
                    decoration: const InputDecoration(labelText: 'Subject Code'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: controller.descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: controller.gradeLevelController,
                    decoration: const InputDecoration(labelText: 'Grade Level'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: controller.categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: controller.saveItem,
              child: Text(controller.isEditing.value ? 'Save Changes' : 'Create Subject'),
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
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
