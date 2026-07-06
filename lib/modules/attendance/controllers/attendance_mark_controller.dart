import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/network/connectivity_service.dart';
import 'package:taleem/core/services/sync_service.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/attendance_model.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/data/repositories/attendance_repository.dart';

class AttendanceMarkController extends GetxController {
  final AttendanceRepository _attendanceRepository = Get.find<AttendanceRepository>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final SyncService _syncService = Get.find<SyncService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<StudentModel> students = <StudentModel>[].obs;
  final RxMap<String, AttendanceStatus> attendanceMap = <String, AttendanceStatus>{}.obs;
  final RxMap<String, String> noteMap = <String, String>{}.obs;

  final RxString selectedBatchId = 'CS-101'.obs; // Default selected batch
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final RxList<Map<String, String>> batches = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBatches();
    loadStudentsAndAttendance();
  }

  void _loadBatches() {
    batches.assignAll([
      {'id': 'CS-101', 'name': 'CS-101 (Morning)'},
      {'id': 'PHY-202', 'name': 'PHY-202 (Evening)'},
      {'id': 'MTH-303', 'name': 'MTH-303 (Afternoon)'},
    ]);
  }

  Future<void> loadStudentsAndAttendance() async {
    isLoading.value = true;
    students.clear();
    attendanceMap.clear();
    noteMap.clear();

    try {
      // 1. Fetch all active students in the system (or filtered by batchId)
      final studentSnap = await _firestore
          .collection(FirebasePaths.students)
          .where('status', isEqualTo: StudentStatus.active.name)
          .get();
      
      final allStudents = studentSnap.docs.map((doc) => StudentModel.fromJson(doc.data())).toList();
      
      // Filter by selectedBatchId
      final batchStudents = allStudents.where((s) => s.batchIds.contains(selectedBatchId.value)).toList();
      students.assignAll(batchStudents);

      // 2. Fetch existing attendance records for the selected batch & date
      final existingAttendance = await _attendanceRepository.getBatchAttendanceForDate(
        selectedBatchId.value,
        selectedDate.value,
      );

      // 3. Initialize mapping (default present if no record exists)
      for (final s in batchStudents) {
        final match = existingAttendance.firstWhereOrNull((a) => a.studentId == s.id);
        if (match != null) {
          attendanceMap[s.id] = match.status;
          if (match.note != null) noteMap[s.id] = match.note!;
        } else {
          attendanceMap[s.id] = AttendanceStatus.present;
        }
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Students', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void updateStatus(String studentId, AttendanceStatus status) {
    attendanceMap[studentId] = status;
  }

  void updateNote(String studentId, String note) {
    noteMap[studentId] = note;
  }

  void markAllPresent() {
    for (final s in students) {
      attendanceMap[s.id] = AttendanceStatus.present;
    }
  }

  void markAllAbsent() {
    for (final s in students) {
      attendanceMap[s.id] = AttendanceStatus.absent;
    }
  }

  Future<void> saveAttendance() async {
    if (students.isEmpty) return;

    isSaving.value = true;
    Helpers.showLoadingDialog('Saving Attendance...');

    // Generate Attendance Records list
    final records = <AttendanceModel>[];
    final dateVal = selectedDate.value;

    for (final s in students) {
      final status = attendanceMap[s.id] ?? AttendanceStatus.present;
      final note = noteMap[s.id];

      // Formulate unique document ID for this day & student: {studentId}_{YYYYMMDD}
      final dateStr = '${dateVal.year}${dateVal.month.toString().padLeft(2, '0')}${dateVal.day.toString().padLeft(2, '0')}';
      final recordId = '${s.id}_$dateStr';

      records.add(AttendanceModel(
        id: recordId,
        studentId: s.id,
        batchId: selectedBatchId.value,
        date: dateVal,
        status: status,
        markedAt: DateTime.now(),
        note: note,
      ));
    }

    try {
      if (_connectivity.isConnected.value) {
        // Online Save: Save Records + Update Student Summaries + Generate Absence Reminders
        await _attendanceRepository.saveBulkAttendance(records);
        await _updateStudentSummariesAndReminders(records);
        
        Helpers.hideLoadingDialog();
        Helpers.showSnackbar(title: 'Success', message: 'Attendance records saved successfully');
      } else {
        // Offline Save: Queue in SyncService
        for (final record in records) {
          await _syncService.queueOperation(
            collection: FirebasePaths.attendance,
            id: record.id,
            action: 'create',
            data: record.toJson(),
          );
        }
        
        Helpers.hideLoadingDialog();
        Helpers.showSnackbar(
          title: 'Offline Saved',
          message: 'Attendance stored locally. Will sync automatically upon reconnection.',
        );
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Save', message: appEx.message, isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  // Updates student attendance percentages and creates notifications for absences in Firestore
  Future<void> _updateStudentSummariesAndReminders(List<AttendanceModel> records) async {
    final batch = _firestore.batch();

    for (final record in records) {
      // 1. If marked absent, create an Absence document for the WhatsApp Reminder Center module
      if (record.status == AttendanceStatus.absent) {
        final absenceId = 'abs_${record.id}';
        final absenceRef = _firestore.collection('absences').doc(absenceId);
        
        // Find corresponding student parent details
        final student = students.firstWhereOrNull((s) => s.id == record.studentId);
        final parentId = student?.parentId;
        
        batch.set(absenceRef, {
          'id': absenceId,
          'studentId': record.studentId,
          'studentName': student?.name ?? 'Student',
          'batchId': record.batchId,
          'date': Timestamp.fromDate(record.date),
          'parentId': parentId,
          'reminderStatus': 'pending', // pending, sent, failed
          'createdAt': Timestamp.fromDate(DateTime.now()),
        }, SetOptions(merge: true));
      }

      // 2. Increment student total count stats (for attendance summaries)
      // In production, we run transactions. For a batch operation we increment locally or merge metrics.
      // We will perform field increments:
      final studentRef = _firestore.collection(FirebasePaths.students).doc(record.studentId);
      final isPresent = record.status == AttendanceStatus.present || record.status == AttendanceStatus.late;
      
      batch.update(studentRef, {
        'totalClasses': FieldValue.increment(1),
        if (isPresent) 'presentClasses': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    await batch.commit();
  }
}
