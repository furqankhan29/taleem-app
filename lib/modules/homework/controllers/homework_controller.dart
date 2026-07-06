import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/homework_model.dart';
import 'package:taleem/data/repositories/homework_repository.dart';

class HomeworkController extends GetxController {
  final HomeworkRepository _homeworkRepository = Get.find<HomeworkRepository>();

  final RxList<HomeworkModel> items = <HomeworkModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedBatchId = ''.obs;
  final RxString selectedSubjectId = ''.obs;
  final Rxn<HomeworkStatus> selectedStatus = Rxn<HomeworkStatus>();
  final RxString sortByField = 'dueDate'.obs;
  final RxBool sortDescending = false.obs;
  DocumentSnapshot? _lastDoc;
  static const int _limit = 20;

  final Rxn<HomeworkModel> item = Rxn<HomeworkModel>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<DateTime> dueDate = DateTime.now().add(const Duration(days: 7)).obs;
  final RxString formBatchId = ''.obs;
  final RxString formSubjectId = ''.obs;
  final Rx<HomeworkStatus> formStatus = HomeworkStatus.active.obs;
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
    titleController.dispose();
    descriptionController.dispose();
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
      final snap = await _homeworkRepository.queryHomework(
        searchQuery: searchQuery.value,
        batchId: selectedBatchId.value.isNotEmpty ? selectedBatchId.value : null,
        subjectId: selectedSubjectId.value.isNotEmpty ? selectedSubjectId.value : null,
        status: selectedStatus.value,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => HomeworkModel.fromJson(doc.data())).toList();
        items.addAll(list);
        hasMore.value = list.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Homework', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreItems() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;

    try {
      final snap = await _homeworkRepository.queryHomework(
        searchQuery: searchQuery.value,
        batchId: selectedBatchId.value.isNotEmpty ? selectedBatchId.value : null,
        subjectId: selectedSubjectId.value.isNotEmpty ? selectedSubjectId.value : null,
        status: selectedStatus.value,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => HomeworkModel.fromJson(doc.data())).toList();
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

  void updateFilters({String? batchId, String? subjectId, HomeworkStatus? status}) {
    selectedBatchId.value = batchId ?? '';
    selectedSubjectId.value = subjectId ?? '';
    selectedStatus.value = status;
    loadItems(refresh: true);
  }

  void clearFilters() {
    selectedBatchId.value = '';
    selectedSubjectId.value = '';
    selectedStatus.value = null;
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
      final model = await _homeworkRepository.getById(id);
      if (model != null) {
        item.value = model;
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Homework', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void selectDueDate(DateTime date) {
    dueDate.value = date;
  }

  void populateForm(HomeworkModel? model) {
    if (model != null) {
      isEditing.value = true;
      titleController.text = model.title;
      descriptionController.text = model.description ?? '';
      dueDate.value = model.dueDate;
      formBatchId.value = model.batchId;
      formSubjectId.value = model.subjectId;
      formStatus.value = model.status;
    } else {
      isEditing.value = false;
      titleController.clear();
      descriptionController.clear();
      dueDate.value = DateTime.now().add(const Duration(days: 7));
      formBatchId.value = '';
      formSubjectId.value = '';
      formStatus.value = HomeworkStatus.active;
    }
  }

  void clearForm() {
    populateForm(null);
  }

  Future<void> saveItem() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    Helpers.showLoadingDialog(isEditing.value ? 'Updating Homework...' : 'Creating Homework...');

    try {
      final idStr = isEditing.value ? item.value!.id : Helpers.generateUniqueId();

      final model = HomeworkModel(
        id: idStr,
        batchId: formBatchId.value,
        subjectId: formSubjectId.value,
        teacherId: isEditing.value ? item.value!.teacherId : '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty ? descriptionController.text.trim() : null,
        dueDate: dueDate.value,
        status: formStatus.value,
        createdAt: isEditing.value ? item.value!.createdAt : DateTime.now(),
      );

      if (isEditing.value) {
        await _homeworkRepository.update(model);
      } else {
        await _homeworkRepository.create(model);
      }

      if (Get.isRegistered<HomeworkController>()) {
        Get.find<HomeworkController>().loadItems(refresh: true);
      }

      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(
        title: 'Success',
        message: isEditing.value ? 'Homework updated successfully' : 'Homework created successfully',
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
    Helpers.showLoadingDialog('Deleting Homework...');
    try {
      await _homeworkRepository.delete(id);
      items.removeWhere((s) => s.id == id);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Homework deleted successfully');
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Delete Failed', message: appEx.message, isError: true);
    }
  }
}
