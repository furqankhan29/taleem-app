import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/validators.dart';
import 'package:taleem/modules/students/controllers/student_form_controller.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';

class StudentFormScreen extends GetView<StudentFormController> {
  const StudentFormScreen({super.key});

  void _showImagePickerOptions(BuildContext context) {
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
            Text(
              'Select Profile Picture',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    controller.pickProfileImage(ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    controller.pickProfileImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28.0),
          ),
          const SizedBox(height: 8.0),
          Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit Profile' : 'Register Student'),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isSaving.value || controller.isLoading.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar selector
                    Center(
                      child: GestureDetector(
                        onTap: () => _showImagePickerOptions(context),
                        child: Stack(
                          children: [
                            Obx(() {
                              if (controller.selectedImagePath.value.isNotEmpty) {
                                return CircleAvatar(
                                  radius: 60.0,
                                  backgroundImage: FileImage(File(controller.selectedImagePath.value)),
                                );
                              }
                              return AvatarWidget(
                                imageUrl: controller.studentToEdit?.photoUrl,
                                name: controller.nameController.text.isNotEmpty 
                                    ? controller.nameController.text 
                                    : 'New Student',
                                size: 120.0,
                              );
                            }),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Section: Student Info
                    _buildSectionHeader('Student Personal Info'),
                    const SizedBox(height: 12.0),
                    GlassCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.nameController,
                            decoration: const InputDecoration(labelText: 'Full Name *'),
                            validator: (val) => Validators.requiredField(val, fieldName: 'Name'),
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: controller.emailController,
                            decoration: const InputDecoration(labelText: 'Email Address'),
                            validator: (val) => (val == null || val.isEmpty) ? null : Validators.email(val),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: controller.phoneController,
                            decoration: const InputDecoration(labelText: 'Phone Number'),
                            validator: (val) => (val == null || val.isEmpty) ? null : Validators.phone(val),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller.dobController,
                                  decoration: const InputDecoration(
                                    labelText: 'Date of Birth',
                                    suffixIcon: Icon(Icons.calendar_today_rounded),
                                  ),
                                  readOnly: true,
                                  onTap: () => controller.selectDateOfBirth(context),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.genderController,
                                  decoration: const InputDecoration(labelText: 'Gender'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller.bloodGroupController,
                                  decoration: const InputDecoration(labelText: 'Blood Group'),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: controller.addressController,
                            decoration: const InputDecoration(labelText: 'Home Address'),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Section: Academic Info
                    _buildSectionHeader('Academic details'),
                    const SizedBox(height: 12.0),
                    GlassCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller.gradeController,
                                  decoration: const InputDecoration(labelText: 'Grade *'),
                                  validator: (val) => Validators.requiredField(val, fieldName: 'Grade'),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.sectionController,
                                  decoration: const InputDecoration(labelText: 'Section'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: controller.streamController,
                            decoration: const InputDecoration(labelText: 'Stream / Track (e.g. Science)'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Section: Batch Assignment
                    _buildSectionHeader('Batch Assignment'),
                    const SizedBox(height: 12.0),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assign Batches',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8.0),
                          Obx(() => Wrap(
                                spacing: 8.0,
                                children: controller.availableBatches.map((batch) {
                                  final isSelected = controller.selectedBatchIds.contains(batch['id']);
                                  return ChoiceChip(
                                    label: Text(batch['name']!),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        controller.selectedBatchIds.add(batch['id']!);
                                      } else {
                                        controller.selectedBatchIds.remove(batch['id']!);
                                      }
                                    },
                                  );
                                }).toList(),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Section: Parent / Guardian Info
                    _buildSectionHeader('Parent / Guardian Details'),
                    const SizedBox(height: 12.0),
                    GlassCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.parentNameController,
                            decoration: const InputDecoration(labelText: 'Guardian Name *'),
                            validator: (val) => Validators.requiredField(val, fieldName: 'Guardian Name'),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller.parentRelationController,
                                  decoration: const InputDecoration(labelText: 'Relation * (e.g. Father)'),
                                  validator: (val) => Validators.requiredField(val, fieldName: 'Relation'),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.parentPhoneController,
                                  decoration: const InputDecoration(labelText: 'Primary Contact *'),
                                  validator: Validators.phone,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller.parentEmailController,
                                  decoration: const InputDecoration(labelText: 'Parent Email'),
                                  validator: (val) => (val == null || val.isEmpty) ? null : Validators.email(val),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.parentWhatsAppController,
                                  decoration: const InputDecoration(labelText: 'Parent WhatsApp'),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    ElevatedButton(
                      onPressed: controller.saveStudent,
                      child: Text(controller.isEditing ? 'Save Changes' : 'Register Student'),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 18.0),
      ),
    );
  }
}
