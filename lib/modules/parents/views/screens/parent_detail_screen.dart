import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/parent_model.dart';
import 'package:taleem/data/repositories/parent_repository.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/confirm_dialog.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';

class ParentDetailScreen extends StatefulWidget {
  const ParentDetailScreen({super.key});

  @override
  State<ParentDetailScreen> createState() => _ParentDetailScreenState();
}

class _ParentDetailScreenState extends State<ParentDetailScreen> {
  final ParentRepository _repository = Get.find<ParentRepository>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController relationCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController whatsappCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController occupationCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;
  final Rxn<ParentModel> parent = Rxn<ParentModel>();

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;
    if (argument is ParentModel) {
      parent.value = argument;
      _populateFields(argument);
      isLoading.value = false;
    } else {
      isEditing.value = true;
      isLoading.value = false;
    }
  }

  void _populateFields(ParentModel model) {
    nameCtrl.text = model.name;
    relationCtrl.text = model.relation ?? '';
    phoneCtrl.text = model.phone ?? '';
    emailCtrl.text = model.email ?? '';
    whatsappCtrl.text = model.whatsappNumber ?? '';
    addressCtrl.text = model.address ?? '';
    occupationCtrl.text = model.occupation ?? '';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    relationCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    whatsappCtrl.dispose();
    addressCtrl.dispose();
    occupationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    isSaving.value = true;

    try {
      final model = ParentModel(
        id: parent.value?.id ?? Helpers.generateUniqueId(),
        name: nameCtrl.text.trim(),
        relation: relationCtrl.text.trim().isNotEmpty ? relationCtrl.text.trim() : null,
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
        email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
        whatsappNumber: whatsappCtrl.text.trim().isNotEmpty ? whatsappCtrl.text.trim() : null,
        address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
        occupation: occupationCtrl.text.trim().isNotEmpty ? occupationCtrl.text.trim() : null,
        studentIds: parent.value?.studentIds ?? [],
        photoUrl: parent.value?.photoUrl,
      );

      if (parent.value != null) {
        await _repository.update(model);
      } else {
        await _repository.create(model);
      }

      Helpers.showSnackbar(title: 'Success', message: parent.value != null ? 'Parent updated' : 'Parent created');
      Get.back(result: model);
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: e.toString(), isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _delete() async {
    if (parent.value == null) return;
    final confirmed = await ConfirmDialog.show(
      title: 'Delete Parent',
      message: 'Are you sure you want to delete ${parent.value!.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed) {
      await _repository.delete(parent.value!.id);
      Helpers.showSnackbar(title: 'Deleted', message: 'Parent removed successfully');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing.value && parent.value != null ? 'Edit Parent' : parent.value != null ? 'Parent Details' : 'Add Parent'),
        actions: [
          if (parent.value != null && !isEditing.value)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              onPressed: () => isEditing.value = true,
            ),
          if (parent.value != null && isEditing.value)
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
    final p = parent.value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (p != null && !isEditing.value) ...[
              _buildDetailView(p),
            ] else ...[
              _buildEditForm(p),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(p != null ? 'Save Changes' : 'Create Parent'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(ParentModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AvatarWidget(
            imageUrl: p.photoUrl,
            name: p.name,
            size: 80,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(p.name, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
        ),
        if (p.relation != null)
          Center(
            child: Text(
              p.relation!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
            ),
          ),
        const SizedBox(height: 24),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.phone != null) _detailRow(Icons.phone_rounded, 'Phone', p.phone!),
              if (p.email != null) ...[const Divider(), _detailRow(Icons.email_outlined, 'Email', p.email!)],
              if (p.whatsappNumber != null) ...[const Divider(), _detailRow(Icons.chat_rounded, 'WhatsApp', p.whatsappNumber!)],
              if (p.occupation != null) ...[const Divider(), _detailRow(Icons.work_rounded, 'Occupation', p.occupation!)],
              if (p.address != null) ...[const Divider(), _detailRow(Icons.location_on_rounded, 'Address', p.address!)],
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Linked Students (${p.studentIds.length})', style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              if (p.studentIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('No students linked', style: AppTypography.bodySmall),
                ),
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

  Widget _buildEditForm(ParentModel? p) {
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
                controller: relationCtrl,
                decoration: const InputDecoration(labelText: 'Relation (e.g. Father)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: whatsappCtrl,
                decoration: const InputDecoration(labelText: 'WhatsApp Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: occupationCtrl,
                decoration: const InputDecoration(labelText: 'Occupation'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
