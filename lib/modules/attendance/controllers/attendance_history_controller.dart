import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/attendance_model.dart';

class AttendanceHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<AttendanceModel> attendanceHistory = <AttendanceModel>[].obs;
  final RxMap<DateTime, AttendanceStatus> heatmapData = <DateTime, AttendanceStatus>{}.obs;

  final RxString selectedBatchId = 'CS-101'.obs;
  final RxInt presentCount = 0.obs;
  final RxInt absentCount = 0.obs;
  final RxInt leaveCount = 0.obs;
  final RxInt lateCount = 0.obs;
  final RxDouble attendancePercentage = 0.0.obs;
  final RxInt currentStreak = 0.obs;

  final RxString aiAttendanceInsight = ''.obs;
  final RxList<double> monthlyTrends = <double>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendanceAnalytics();
  }

  Future<void> loadAttendanceAnalytics() async {
    isLoading.value = true;
    attendanceHistory.clear();
    heatmapData.clear();
    presentCount.value = 0;
    absentCount.value = 0;
    leaveCount.value = 0;
    lateCount.value = 0;
    attendancePercentage.value = 0.0;
    currentStreak.value = 0;

    try {
      // 1. Fetch attendance records in Firestore for selected batch
      final snap = await _firestore
          .collection(FirebasePaths.attendance)
          .where('batchId', isEqualTo: selectedBatchId.value)
          .orderBy('date', descending: true)
          .get();

      final list = snap.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
      attendanceHistory.assignAll(list);

      // 2. Parse counts & heatmap mapping
      int pres = 0;
      int abs = 0;
      int leav = 0;
      int lat = 0;

      for (final record in list) {
        // Map date normalized to midnight for calendar highlights
        final dateMidnight = DateTime(record.date.year, record.date.month, record.date.day);
        heatmapData[dateMidnight] = record.status;

        switch (record.status) {
          case AttendanceStatus.present:
            pres++;
            break;
          case AttendanceStatus.absent:
            abs++;
            break;
          case AttendanceStatus.leave:
            leav++;
            break;
          case AttendanceStatus.late:
            lat++;
            break;
        }
      }

      presentCount.value = pres;
      absentCount.value = abs;
      leaveCount.value = leav;
      lateCount.value = lat;

      final total = pres + abs + leav + lat;
      if (total > 0) {
        attendancePercentage.value = ((pres + lat) / total) * 100;
      }

      // Calculate simple mock streaks from chronological sorted list
      int streak = 0;
      for (final record in list.reversed) {
        if (record.status == AttendanceStatus.present || record.status == AttendanceStatus.late) {
          streak++;
        } else if (record.status == AttendanceStatus.absent) {
          streak = 0; // broken streak
        }
      }
      currentStreak.value = streak;

      // 3. Load default chart / insight placeholders
      _loadPlaceholderMetrics();
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Analytics Loading Failed', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void _loadPlaceholderMetrics() {
    aiAttendanceInsight.value =
        'Attendance in CS-101 has risen to 94.2% this month, showing a 3.5% increment compared to last term. Absenteeism peaks on Fridays. Suggestion: Automate WhatsApp notifications for parent follow-ups on missing days.';

    // Month-by-month averages for fl_chart
    monthlyTrends.assignAll([82.0, 89.0, 85.0, 93.0, 91.0, 94.2]);
  }
}
