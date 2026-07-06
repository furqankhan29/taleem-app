import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/data/repositories/fee_repository.dart';

class FeeController extends GetxController {
  final FeeRepository _feeRepository = Get.find<FeeRepository>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<FeeModel> feesList = <FeeModel>[].obs;
  final RxList<StudentModel> studentsList = <StudentModel>[].obs;

  final RxDouble totalCollected = 0.0.obs;
  final RxDouble totalPending = 0.0.obs;
  final RxDouble recoveryPercentage = 0.0.obs;

  final RxString selectedBatchId = ''.obs;
  final Rxn<FeePaymentStatus> selectedStatus = Rxn<FeePaymentStatus>();
  final Rxn<FeeType> selectedType = Rxn<FeeType>();
  final RxString searchQuery = ''.obs;

  final RxList<double> revenueTrends = <double>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFinancialData();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final snap = await _firestore.collection(FirebasePaths.students).get();
      studentsList.assignAll(snap.docs.map((doc) => StudentModel.fromJson(doc.data())).toList());
    } catch (_) {}
  }

  Future<void> loadFinancialData() async {
    isLoading.value = true;
    feesList.clear();

    try {
      // 1. Fetch fees according to filters
      final fees = await _feeRepository.getFilteredFees(
        status: selectedStatus.value,
        type: selectedType.value,
        batchId: selectedBatchId.value.isEmpty ? null : selectedBatchId.value,
      );

      // Filter locally by search query (student name)
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchedStudents = studentsList.where((s) => s.name.toLowerCase().contains(query)).map((s) => s.id).toSet();
        feesList.assignAll(fees.where((f) => matchedStudents.contains(f.studentId)).toList());
      } else {
        feesList.assignAll(fees);
      }

      // 2. Fetch Aggregates
      totalCollected.value = await _feeRepository.getTotalCollectedIncome();
      totalPending.value = await _feeRepository.getOutstandingBalance();
      
      final sumAll = totalCollected.value + totalPending.value;
      if (sumAll > 0) {
        recoveryPercentage.value = (totalCollected.value / sumAll) * 100;
      } else {
        recoveryPercentage.value = 0.0;
      }

      // 3. Load revenue trends over months for graph
      _loadPlaceholderTrends();
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Finances', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void _loadPlaceholderTrends() {
    revenueTrends.assignAll([12000.0, 15000.0, 14200.0, 18500.0, 22000.0, 24500.0]);
  }

  // Export collected lists to CSV / Share
  Future<void> exportToCSV() async {
    if (feesList.isEmpty) {
      Helpers.showSnackbar(title: 'No Data', message: 'No financial records available to export', isError: true);
      return;
    }

    try {
      final buffer = StringBuffer();
      // CSV Headers
      buffer.writeln('Fee ID,Student ID,Amount,Due Date,Status,Type,Total Paid,Balance Due');

      for (final f in feesList) {
        final studentName = studentsList.firstWhereOrNull((s) => s.id == f.studentId)?.name ?? f.studentId;
        buffer.writeln(
          '${f.id},"$studentName",${f.amount},"${f.dueDate}",${f.status.name},${f.type.name},${f.totalPaid},${f.balanceDue}',
        );
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/Fee_Report_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles([XFile(file.path)], text: 'Exported Taleem Fee Report');
    } catch (e) {
      Helpers.showSnackbar(title: 'Export Failed', message: e.toString(), isError: true);
    }
  }
}
