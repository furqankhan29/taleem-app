import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/data/repositories/student_repository.dart';

class StudentListController extends GetxController {
  final StudentRepository _studentRepository = Get.find<StudentRepository>();

  final RxList<StudentModel> students = <StudentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;

  // Filters & Search
  final RxString searchQuery = ''.obs;
  final RxnString selectedGrade = RxnString();
  final Rxn<StudentStatus> selectedStatus = Rxn<StudentStatus>();
  final Rxn<FeeStatus> selectedFeeStatus = Rxn<FeeStatus>();

  // Sorting
  final RxString sortByField = 'name'.obs;
  final RxBool sortDescending = false.obs;

  DocumentSnapshot? _lastDoc;
  static const int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    // Debounce search input to avoid hitting Firestore on every key press
    debounce(searchQuery, (_) => loadStudents(refresh: true), time: const Duration(milliseconds: 500));
    loadStudents();
  }

  Future<void> loadStudents({bool refresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    
    if (refresh) {
      _lastDoc = null;
      hasMore.value = true;
      students.clear();
    }

    try {
      final snap = await _studentRepository.queryStudents(
        searchQuery: searchQuery.value,
        grade: selectedGrade.value,
        status: selectedStatus.value,
        feeStatus: selectedFeeStatus.value,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => StudentModel.fromJson(doc.data())).toList();
        students.addAll(list);
        hasMore.value = list.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Students', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreStudents() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;

    try {
      final snap = await _studentRepository.queryStudents(
        searchQuery: searchQuery.value,
        grade: selectedGrade.value,
        status: selectedStatus.value,
        feeStatus: selectedFeeStatus.value,
        sortByField: sortByField.value,
        descending: sortDescending.value,
        startAfterDoc: _lastDoc,
        limit: _limit,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final list = snap.docs.map((doc) => StudentModel.fromJson(doc.data())).toList();
        students.addAll(list);
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

  void updateFilters({
    String? grade,
    StudentStatus? status,
    FeeStatus? feeStatus,
  }) {
    selectedGrade.value = grade;
    selectedStatus.value = status;
    selectedFeeStatus.value = feeStatus;
    loadStudents(refresh: true);
  }

  void clearFilters() {
    selectedGrade.value = null;
    selectedStatus.value = null;
    selectedFeeStatus.value = null;
    searchQuery.value = '';
    loadStudents(refresh: true);
  }

  void updateSorting(String field, bool descending) {
    sortByField.value = field;
    sortDescending.value = descending;
    loadStudents(refresh: true);
  }

  Future<void> deleteStudent(String id) async {
    Helpers.showLoadingDialog('Deleting Student...');
    try {
      await _studentRepository.delete(id);
      students.removeWhere((s) => s.id == id);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Student profile deleted successfully');
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Delete Failed', message: appEx.message, isError: true);
    }
  }
}
