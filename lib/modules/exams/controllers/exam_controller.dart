import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/exam_model.dart';
import 'package:taleem/data/repositories/exam_repository.dart';

class ExamController extends GetxController {
  final ExamRepository _examRepository = Get.find<ExamRepository>();

  final RxList<ExamModel> items = <ExamModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedBatchId = ''.obs;
  final RxString selectedSubjectId = ''.obs;
  final Rxn<ExamStatus> selectedStatus = Rxn<ExamStatus>();
  final RxString sortByField = 'date'.obs;
  final RxBool sortDescending = false.obs;
  DocumentSnapshot? _lastDoc;
  static const int _limit = 20;

  final Rxn<ExamModel> item = Rxn<ExamModel>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final Rx<DateTime> examDate = DateTime.now().add(const Duration(days: 30)).obs;
  final RxInt duration = 60.obs;
  final RxDouble totalMarks = 100.0.obs;
  final RxString formBatchId = ''.obs;
  final RxString formSubjectId = ''.obs;
  final Rx<ExamStatus> formStatus = ExamStatus.scheduled.obs;
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
      final snap = await _examRepository.queryExams(
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
        final list = snap.docs.map((doc) => ExamModel.fromJson(doc.data())).toList();
        items.addAll(list);
        hasMore.value = list.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Exams', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreItems() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;

    try {
      final snap = await _examRepository.queryExams(
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
        final list = snap.docs.map((doc) => ExamModel.fromJson(doc.data())).toList();
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

  void updateFilters({String? batchId, String? subjectId, ExamStatus? status}) {
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
      final model = await _examRepository.getById(id);
      if (model != null) {
        item.value = model;
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Exam', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void selectExamDate(DateTime date) {
    examDate.value = date;
  }

  void populateForm(ExamModel? model) {
    if (model != null) {
      isEditing.value = true;
      nameController.text = model.name;
      examDate.value = model.date;
      duration.value = model.duration;
      totalMarks.value = model.totalMarks;
      formBatchId.value = model.batchId;
      formSubjectId.value = model.subjectId;
      formStatus.value = model.status;
    } else {
      isEditing.value = false;
      nameController.clear();
      examDate.value = DateTime.now().add(const Duration(days: 30));
      duration.value = 60;
      totalMarks.value = 100.0;
      formBatchId.value = '';
      formSubjectId.value = '';
      formStatus.value = ExamStatus.scheduled;
    }
  }

  void clearForm() {
    populateForm(null);
  }

  Future<void> saveItem() async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    Helpers.showLoadingDialog(isEditing.value ? 'Updating Exam...' : 'Creating Exam...');

    try {
      final idStr = isEditing.value ? item.value!.id : Helpers.generateUniqueId();

      final model = ExamModel(
        id: idStr,
        name: nameController.text.trim(),
        batchId: formBatchId.value,
        subjectId: formSubjectId.value,
        date: examDate.value,
        duration: duration.value,
        totalMarks: totalMarks.value,
        status: formStatus.value,
        createdAt: isEditing.value ? item.value!.createdAt : DateTime.now(),
        results: isEditing.value ? item.value!.results : [],
      );

      if (isEditing.value) {
        await _examRepository.update(model);
      } else {
        await _examRepository.create(model);
      }

      if (Get.isRegistered<ExamController>()) {
        Get.find<ExamController>().loadItems(refresh: true);
      }

      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(
        title: 'Success',
        message: isEditing.value ? 'Exam updated successfully' : 'Exam created successfully',
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
    Helpers.showLoadingDialog('Deleting Exam...');
    try {
      await _examRepository.delete(id);
      items.removeWhere((s) => s.id == id);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Exam deleted successfully');
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Delete Failed', message: appEx.message, isError: true);
    }
  }
}
