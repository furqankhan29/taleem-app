import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/subject_model.dart';
import 'package:taleem/data/repositories/subject_repository.dart';

class SubjectController extends GetxController {
  final SubjectRepository _subjectRepository = Get.find<SubjectRepository>();

  final RxList<SubjectModel> items = <SubjectModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGradeLevel = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString sortByField = 'name'.obs;
  final RxBool sortDescending = false.obs;
  DocumentSnapshot? _lastDoc;
  static const int _limit = 20;

  final Rxn<SubjectModel> item = Rxn<SubjectModel>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final gradeLevelController = TextEditingController();
  final categoryController = TextEditingController();
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => loadItems(refresh: true), time: const Duration(milliseconds: 500));
    loadItems();
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    gradeLevelController.dispose();
    categoryController.dispose();
    super.onClose();
  }

  Future<void> loadItems({bool refresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    if (refresh) {
      _lastDoc = null;
      hasMore.value = true;
      items.clear();
    }

    try {
      final snap = await _subjectRepository.querySubjects(
        searchQuery: searchQuery.value,
        gradeLevel: selectedGradeLevel.value.isNotEmpty ? selectedGradeLevel.value : null,
        category: selectedCategory.value.isNotEmpty ? selectedCategory.value : null,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => SubjectModel.fromJson(doc.data())).toList();
        items.addAll(list);
        hasMore.value = list.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Subjects', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreItems() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;

    try {
      final snap = await _subjectRepository.querySubjects(
        searchQuery: searchQuery.value,
        gradeLevel: selectedGradeLevel.value.isNotEmpty ? selectedGradeLevel.value : null,
        category: selectedCategory.value.isNotEmpty ? selectedCategory.value : null,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => SubjectModel.fromJson(doc.data())).toList();
        items.addAll(list);
        hasMore.value = list.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load More', message: appEx.message, isError: true);
    } finally {
      isMoreLoading.value = false;
    }
  }

  void updateFilters({String? gradeLevel, String? category}) {
    selectedGradeLevel.value = gradeLevel ?? '';
    selectedCategory.value = category ?? '';
    loadItems(refresh: true);
  }

  void clearFilters() {
    selectedGradeLevel.value = '';
    selectedCategory.value = '';
    searchQuery.value = '';
    loadItems(refresh: true);
  }

  void updateSorting(String field, bool descending) {
    sortByField.value = field;
    sortDescending.value = descending;
    loadItems(refresh: true);
  }

  Future<void> fetchItem(String id) async {
    isLoading.value = true;
    try {
      final model = await _subjectRepository.getById(id);
      if (model != null) {
        item.value = model;
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Subject', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void populateForm(SubjectModel? model) {
    if (model != null) {
      isEditing.value = true;
      nameController.text = model.name;
      codeController.text = model.code ?? '';
      descriptionController.text = model.description ?? '';
      gradeLevelController.text = model.gradeLevel ?? '';
      categoryController.text = model.category ?? '';
    } else {
      isEditing.value = false;
      nameController.clear();
      codeController.clear();
      descriptionController.clear();
      gradeLevelController.clear();
      categoryController.clear();
    }
  }

  void clearForm() {
    populateForm(null);
  }

  Future<void> saveItem() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    Helpers.showLoadingDialog(isEditing.value ? 'Updating Subject...' : 'Creating Subject...');

    try {
      final idStr = isEditing.value ? item.value!.id : Helpers.generateUniqueId();

      final model = SubjectModel(
        id: idStr,
        name: nameController.text.trim(),
        code: codeController.text.trim().isNotEmpty ? codeController.text.trim() : null,
        description: descriptionController.text.trim().isNotEmpty ? descriptionController.text.trim() : null,
        gradeLevel: gradeLevelController.text.trim().isNotEmpty ? gradeLevelController.text.trim() : null,
        category: categoryController.text.trim().isNotEmpty ? categoryController.text.trim() : null,
      );

      if (isEditing.value) {
        await _subjectRepository.update(model);
      } else {
        await _subjectRepository.create(model);
      }

      if (Get.isRegistered<SubjectController>()) {
        Get.find<SubjectController>().loadItems(refresh: true);
      }

      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(
        title: 'Success',
        message: isEditing.value ? 'Subject updated successfully' : 'Subject created successfully',
      );
      Get.back(result: model);
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Save', message: appEx.message, isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteItem(String id) async {
    Helpers.showLoadingDialog('Deleting Subject...');
    try {
      await _subjectRepository.delete(id);
      items.removeWhere((s) => s.id == id);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Subject deleted successfully');
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Delete Failed', message: appEx.message, isError: true);
    }
  }
}
