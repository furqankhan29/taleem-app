import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/services/storage_service.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/parent_model.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/data/repositories/student_repository.dart';
import 'package:taleem/modules/students/controllers/student_list_controller.dart';

class StudentFormController extends GetxController {
  final StudentRepository _studentRepository = Get.find<StudentRepository>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final gradeController = TextEditingController();
  final sectionController = TextEditingController();
  final streamController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();

  // Parent fields
  final parentNameController = TextEditingController();
  final parentRelationController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final parentEmailController = TextEditingController();
  final parentWhatsAppController = TextEditingController();

  final RxString selectedImagePath = ''.obs;
  final RxList<String> selectedBatchIds = <String>[].obs;
  final RxList<Map<String, dynamic>> availableBatches = <Map<String, dynamic>>[].obs;

  final RxBool isSaving = false.obs;
  final RxBool isLoading = false.obs;

  bool isEditing = false;
  StudentModel? studentToEdit;
  DateTime? _selectedDob;

  @override
  void onInit() {
    super.onInit();
    _loadAvailableBatches();
    
    // Check if editing
    final arguments = Get.arguments;
    if (arguments != null && arguments is StudentModel) {
      isEditing = true;
      studentToEdit = arguments;
      _populateFieldsForEditing(arguments);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    gradeController.dispose();
    sectionController.dispose();
    streamController.dispose();
    bloodGroupController.dispose();
    dobController.dispose();
    genderController.dispose();
    
    parentNameController.dispose();
    parentRelationController.dispose();
    parentPhoneController.dispose();
    parentEmailController.dispose();
    parentWhatsAppController.dispose();
    
    super.dispose();
  }

  void _loadAvailableBatches() {
    // Populate with stub batches to select from
    availableBatches.assignAll([
      {'id': 'CS-101', 'name': 'CS-101 (Morning)'},
      {'id': 'PHY-202', 'name': 'PHY-202 (Evening)'},
      {'id': 'MTH-303', 'name': 'MTH-303 (Afternoon)'},
    ]);
  }

  void _populateFieldsForEditing(StudentModel s) {
    nameController.text = s.name;
    emailController.text = s.email ?? '';
    phoneController.text = s.phone ?? '';
    addressController.text = s.address ?? '';
    gradeController.text = s.grade ?? '';
    sectionController.text = s.section ?? '';
    streamController.text = s.stream ?? '';
    bloodGroupController.text = s.bloodGroup ?? '';
    genderController.text = s.gender ?? '';
    selectedBatchIds.assignAll(s.batchIds);

    if (s.dateOfBirth != null) {
      _selectedDob = s.dateOfBirth;
      dobController.text = Formatters.formatDate(s.dateOfBirth!);
    }

    // Load parent details if exist
    if (s.parentId != null && s.parentId!.isNotEmpty) {
      _loadParentFields(s.parentId!);
    }
  }

  Future<void> _loadParentFields(String parentId) async {
    isLoading.value = true;
    try {
      final doc = await _firestore.collection(FirebasePaths.parents).doc(parentId).get();
      if (doc.exists && doc.data() != null) {
        final p = ParentModel.fromJson(doc.data()!);
        parentNameController.text = p.name;
        parentRelationController.text = p.relation ?? '';
        parentPhoneController.text = p.phone ?? '';
        parentEmailController.text = p.email ?? '';
        parentWhatsAppController.text = p.whatsappNumber ?? '';
      }
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(imageQuality: 70, source: source);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Helpers.showSnackbar(title: 'Image Pick Failed', message: e.toString(), isError: true);
    }
  }

  Future<void> selectDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _selectedDob = picked;
      dobController.text = Formatters.formatDate(picked);
    }
  }

  Future<void> saveStudent() async {
    if (!formKey.currentState!.validate()) return;
    
    isSaving.value = true;
    Helpers.showLoadingDialog(isEditing ? 'Updating Student...' : 'Registering Student...');

    try {
      final studentIdStr = isEditing ? studentToEdit!.id : Helpers.generateUniqueId();
      
      // Auto Student ID generation (STU-YYYY-NNNN)
      String finalStudentIdCode;
      if (isEditing) {
        finalStudentIdCode = studentToEdit!.studentId;
      } else {
        final totalCount = await _studentRepository.getStudentCount();
        finalStudentIdCode = Formatters.generateStudentId(totalCount + 1);
      }

      // Handle Image Upload to Firebase Storage
      String? photoUrl = isEditing ? studentToEdit!.photoUrl : null;
      if (selectedImagePath.value.isNotEmpty) {
        photoUrl = await _uploadImageToFirebaseStorage(studentIdStr, selectedImagePath.value);
      }

      // Create Parent Document
      final parentIdStr = isEditing && studentToEdit!.parentId != null
          ? studentToEdit!.parentId!
          : Helpers.generateUniqueId();

      final parentModel = ParentModel(
        id: parentIdStr,
        name: parentNameController.text.trim(),
        relation: parentRelationController.text.trim(),
        phone: parentPhoneController.text.trim(),
        email: parentEmailController.text.trim(),
        whatsappNumber: parentWhatsAppController.text.trim(),
        studentIds: [studentIdStr],
        address: addressController.text.trim(),
      );

      await _firestore
          .collection(FirebasePaths.parents)
          .doc(parentIdStr)
          .set(parentModel.toJson(), SetOptions(merge: true));

      // Build Student Document
      final studentModel = StudentModel(
        id: studentIdStr,
        name: nameController.text.trim(),
        email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
        phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
        photoUrl: photoUrl,
        studentId: finalStudentIdCode,
        grade: gradeController.text.trim().isNotEmpty ? gradeController.text.trim() : null,
        section: sectionController.text.trim().isNotEmpty ? sectionController.text.trim() : null,
        stream: streamController.text.trim().isNotEmpty ? streamController.text.trim() : null,
        bloodGroup: bloodGroupController.text.trim().isNotEmpty ? bloodGroupController.text.trim() : null,
        parentId: parentIdStr,
        batchIds: selectedBatchIds,
        status: isEditing ? studentToEdit!.status : StudentStatus.active,
        feeStatus: isEditing ? studentToEdit!.feeStatus : FeeStatus.pending,
        createdAt: isEditing ? studentToEdit!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        qrCodeData: finalStudentIdCode, // Saves the student ID code as QR Data
        address: addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
        dateOfBirth: _selectedDob,
        gender: genderController.text.trim().isNotEmpty ? genderController.text.trim() : null,
      );

      // Save Student to Repository/Firestore
      if (isEditing) {
        await _studentRepository.update(studentModel);
      } else {
        await _studentRepository.create(studentModel);
      }

      // Refresh Student list
      if (Get.isRegistered<StudentListController>()) {
        Get.find<StudentListController>().loadStudents(refresh: true);
      }

      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(
        title: 'Success',
        message: isEditing ? 'Student profile updated' : 'Student registered successfully',
      );
      Get.back(result: studentModel);
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Save', message: appEx.message, isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<String> _uploadImageToFirebaseStorage(String id, String path) async {
    final storageService = Get.find<StorageService>();
    final storagePath = StorageService.getStudentPhotoPath(id);
    return await storageService.uploadFile(
      file: File(path),
      path: storagePath,
    );
  }
}
