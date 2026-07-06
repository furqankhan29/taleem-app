import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/logger.dart';
import 'package:taleem/data/models/attendance_model.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/data/models/parent_model.dart';
import 'package:taleem/data/repositories/attendance_repository.dart';
import 'package:taleem/data/repositories/fee_repository.dart';
import 'package:taleem/data/repositories/student_repository.dart';

class StudentDetailController extends GetxController {
  final StudentRepository _studentRepository = Get.find<StudentRepository>();
  late final AttendanceRepository _attendanceRepository;
  late final FeeRepository _feeRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<StudentModel> student = Rxn<StudentModel>();
  final Rxn<ParentModel> parent = Rxn<ParentModel>();
  final RxInt activeTab = 0.obs; // 0=Overview, 1=Attendance Heatmap, 2=Academics, 3=Fees, 4=Documents
  final RxBool isLoading = false.obs;

  // Student specific data logs/metrics
  final RxString aiPerformanceInsight = ''.obs;
  final RxList<double> academicTrajectory = <double>[].obs;
  final RxList<Map<String, dynamic>> activityLogs = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> studentStats = <String, dynamic>{}.obs;
  final RxMap<DateTime, AttendanceStatus> attendanceHeatmap = <DateTime, AttendanceStatus>{}.obs;
  final RxList<FeeModel> studentFees = <FeeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _attendanceRepository = Get.isRegistered<AttendanceRepository>()
        ? Get.find<AttendanceRepository>()
        : Get.put(AttendanceRepository(firebaseProvider: Get.find()));
    _feeRepository = Get.isRegistered<FeeRepository>()
        ? Get.find<FeeRepository>()
        : Get.put(FeeRepository(firebaseProvider: Get.find()));
  }

  Future<void> fetchStudentDetails(String id) async {
    isLoading.value = true;
    try {
      final model = await _studentRepository.getById(id);
      if (model != null) {
        student.value = model;
        
        // Fetch Parent Profile
        if (model.parentId != null && model.parentId!.isNotEmpty) {
          await _fetchParentProfile(model.parentId!);
        }

        // Fetch Overview Details
        _loadDefaultDesignData();
        await _fetchStudentOverviewData(id);
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Load Details', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchParentProfile(String parentId) async {
    try {
      final doc = await _firestore.collection(FirebasePaths.parents).doc(parentId).get();
      if (doc.exists && doc.data() != null) {
        parent.value = ParentModel.fromJson(doc.data()!);
      }
    } catch (_) {}
  }

  void _loadDefaultDesignData() {
    // Exact text from student_profile_v2 design
    aiPerformanceInsight.value =
        'Sarah is maintaining a strong upper-quartile position, particularly excelling in STEM subjects. Recent trends show a 12% improvement in Physics over the last term. Attendance is consistent at 96%. Recommendation: Consider advanced placement for Mathematics next semester.';

    academicTrajectory.assignAll([22.0, 39.0, 35.0, 68.0, 58.0, 85.0]); // Matches line chart curve peaks in design

    studentStats.assignAll({
      'classRank': '4/120',
      'demerits': '0',
      'feeStatus': 'Cleared',
      'awards': '3',
    });

    activityLogs.assignAll([
      {
        'title': 'Midterm Results Published',
        'subtitle': 'Scored 92% aggregate. Top 5% in Science.',
        'time': 'Today, 10:30 AM',
        'icon': 'assessment',
        'color': 'primary',
      },
      {
        'title': 'Absent - Sick Leave',
        'subtitle': 'Medical certificate uploaded and verified by admin.',
        'time': 'Oct 12, 2023',
        'icon': 'event_busy',
        'color': 'error',
      },
      {
        'title': 'Term 2 Fee Paid',
        'subtitle': 'Amount: \$1,200. Receipt sent to parent\'s email.',
        'time': 'Oct 01, 2023',
        'icon': 'payments',
        'color': 'secondary',
      },
      {
        'title': 'PTM Scheduled',
        'subtitle': 'Meeting confirmed with Mr. Jenkins for next week.',
        'time': 'Sep 28, 2023',
        'icon': 'forum',
        'color': 'primary',
      }
    ]);
  }

  Future<void> _fetchStudentOverviewData(String studentId) async {
    try {
      final records = await _attendanceRepository.getStudentAttendance(studentId);
      
      attendanceHeatmap.clear();
      for (final r in records) {
        final dateMidnight = DateTime(r.date.year, r.date.month, r.date.day);
        attendanceHeatmap[dateMidnight] = r.status;
      }

      final fees = await _feeRepository.getStudentFees(studentId);
      studentFees.assignAll(fees);
    } catch (e) {
      Logger.error('Failed to fetch real-time overview metrics.', e);
    }
  }

  void changeTab(int index) {
    activeTab.value = index;
  }
}
