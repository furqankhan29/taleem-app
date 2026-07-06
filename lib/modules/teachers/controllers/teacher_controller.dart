import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/teacher_model.dart';
import 'package:taleem/data/repositories/teacher_repository.dart';

class TeacherController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final RxList<TeacherModel> items = <TeacherModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString error = ''.obs;

  final RxString searchQuery = ''.obs;
  final Rxn<TeacherStatus> selectedStatus = Rxn<TeacherStatus>();
  final RxString sortByField = 'name'.obs;
  final RxBool sortDescending = false.obs;

  DocumentSnapshot? _lastDoc;
  static const int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => loadItems(refresh: true), time: const Duration(milliseconds: 500));
    loadItems();
  }

  Future<void> loadItems({bool refresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    if (refresh) {
      _lastDoc = null;
      hasMore.value = true;
      items.clear();
    }

    try {
      final snap = await _teacherRepository.queryTeachers(
        searchQuery: searchQuery.value,
        status: selectedStatus.value,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => TeacherModel.fromJson(doc.data())).toList();
        items.addAll(list);
        hasMore.value = list.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      error.value = ErrorHandler.handleError(e).message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreItems() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;

    try {
      final snap = await _teacherRepository.queryTeachers(
        searchQuery: searchQuery.value,
        status: selectedStatus.value,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => TeacherModel.fromJson(doc.data())).toList();
        items.addAll(list);
        hasMore.value = list.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      Helpers.showSnackbar(title: 'Failed to Load More', message: ErrorHandler.handleError(e).message, isError: true);
    } finally {
      isMoreLoading.value = false;
    }
  }

  Future<void> create(TeacherModel model) async {
    Helpers.showLoadingDialog('Creating Teacher...');
    try {
      await _teacherRepository.create(model);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Teacher created successfully');
      loadItems(refresh: true);
      Get.back();
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Failed to Create', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> updateItem(TeacherModel model) async {
    Helpers.showLoadingDialog('Updating Teacher...');
    try {
      await _teacherRepository.update(model);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Teacher updated successfully');
      loadItems(refresh: true);
      Get.back();
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Failed to Update', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> delete(String id) async {
    Helpers.showLoadingDialog('Deleting Teacher...');
    try {
      await _teacherRepository.delete(id);
      items.removeWhere((s) => s.id == id);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Teacher deleted successfully');
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Delete Failed', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> toggleStatus(TeacherModel model) async {
    final newStatus = model.status == TeacherStatus.active ? TeacherStatus.inactive : TeacherStatus.active;
    final updated = model.copyWith(status: newStatus);
    await updateItem(updated);
  }

  void updateFilters({TeacherStatus? status}) {
    selectedStatus.value = status;
    loadItems(refresh: true);
  }

  void clearFilters() {
    selectedStatus.value = null;
    searchQuery.value = '';
    loadItems(refresh: true);
  }

  void updateSorting(String field, bool descending) {
    sortByField.value = field;
    sortDescending.value = descending;
    loadItems(refresh: true);
  }
}
