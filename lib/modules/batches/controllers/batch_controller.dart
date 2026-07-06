import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/batch_model.dart';
import 'package:taleem/data/repositories/batch_repository.dart';

class BatchController extends GetxController {
  final BatchRepository _batchRepository = Get.find<BatchRepository>();

  final RxList<BatchModel> items = <BatchModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString error = ''.obs;

  final RxString searchQuery = ''.obs;
  final Rxn<BatchSchedule> selectedSchedule = Rxn<BatchSchedule>();
  final Rxn<BatchStatus> selectedStatus = Rxn<BatchStatus>();
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
      final snap = await _batchRepository.queryBatches(
        searchQuery: searchQuery.value,
        schedule: selectedSchedule.value,
        status: selectedStatus.value,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => BatchModel.fromJson(doc.data())).toList();
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
      final snap = await _batchRepository.queryBatches(
        searchQuery: searchQuery.value,
        schedule: selectedSchedule.value,
        status: selectedStatus.value,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => BatchModel.fromJson(doc.data())).toList();
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

  Future<void> create(BatchModel model) async {
    Helpers.showLoadingDialog('Creating Batch...');
    try {
      await _batchRepository.create(model);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Batch created successfully');
      loadItems(refresh: true);
      Get.back();
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Failed to Create', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> updateItem(BatchModel model) async {
    Helpers.showLoadingDialog('Updating Batch...');
    try {
      await _batchRepository.update(model);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Batch updated successfully');
      loadItems(refresh: true);
      Get.back();
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Failed to Update', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> delete(String id) async {
    Helpers.showLoadingDialog('Deleting Batch...');
    try {
      await _batchRepository.delete(id);
      items.removeWhere((s) => s.id == id);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Batch deleted successfully');
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Delete Failed', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> toggleStatus(BatchModel model) async {
    final newStatus = model.status == BatchStatus.active ? BatchStatus.inactive : BatchStatus.active;
    final updated = model.copyWith(status: newStatus);
    await updateItem(updated);
  }

  void updateFilters({BatchSchedule? schedule, BatchStatus? status}) {
    selectedSchedule.value = schedule;
    selectedStatus.value = status;
    loadItems(refresh: true);
  }

  void clearFilters() {
    selectedSchedule.value = null;
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
