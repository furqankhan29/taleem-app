import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/attendance_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class AttendanceRepository extends BaseRepository<AttendanceModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AttendanceRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.attendance);

  @override
  AttendanceModel fromJson(Map<String, dynamic> json) => AttendanceModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(AttendanceModel model) => model.toJson();

  @override
  String getModelId(AttendanceModel model) => model.id;

  // Retrieve attendance for a batch on a specific date
  Future<List<AttendanceModel>> getBatchAttendanceForDate(String batchId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snap = await _firestore
        .collection(FirebasePaths.attendance)
        .where('batchId', isEqualTo: batchId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snap.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
  }

  // Retrieve attendance for a student
  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    final snap = await _firestore
        .collection(FirebasePaths.attendance)
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .get();

    return snap.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
  }

  // Bulk Attendance Marking using a Firestore Batch Write
  Future<void> saveBulkAttendance(List<AttendanceModel> attendanceRecords) async {
    final batch = _firestore.batch();

    for (final record in attendanceRecords) {
      final docRef = _firestore.collection(FirebasePaths.attendance).doc(record.id);
      batch.set(docRef, record.toJson(), SetOptions(merge: true));

      // Update Student's overall attendance stats/summary
      // In a real app we can increment/decrement total present/absent counters in a Firestore Transaction or Cloud Function.
      // Here, we perform a merge update on the student document or a sub-collection stats document.
      // We will perform stats updates incrementally or in transaction.
      // For simplicity, we save the log. Summary updates will happen in the marking controller.
    }

    await batch.commit();
  }
}
