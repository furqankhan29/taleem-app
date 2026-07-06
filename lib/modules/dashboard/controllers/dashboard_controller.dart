import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/utils/logger.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _activitiesSubscription;

  // KPIs
  final RxInt totalStudents = 1248.obs;
  final RxInt activeNow = 342.obs;
  final RxDouble attendanceRate = 94.2.obs;
  final RxDouble feeCollection = 45.2.obs; // in thousands ($45.2k)

  // Subsections
  final RxList<Map<String, dynamic>> upcomingClasses = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;
  final RxList<double> monthlyIncomeData = <double>[12000, 19000, 15000, 22000, 28000, 24000].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    _listenToRecentActivities();
  }

  @override
  void onClose() {
    _activitiesSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // Define default data that matches design mockups
      _loadDefaultDesignData();

      // Attempt live firestore queries in try-catch so it won't crash if collections are empty or offline
      await Future.wait([
        _fetchLiveKpis(),
        _fetchLiveUpcomingClasses(),
      ]);
    } catch (e) {
      Logger.error('Failed to query live dashboard data, using local fallback.', e);
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDefaultDesignData() {
    upcomingClasses.assignAll([
      {
        'time': '10:00 AM - 11:30 AM',
        'title': 'Advanced Physics',
        'grade': 'Grade 12',
        'room': 'Room A1',
        'type': 'physics',
        'students': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCP8ZFD8PZbeOka0jjRtxKNAyL65qKWGn0EB8zWFIehoz5FCes1gKwbEIujQcrSF9YzTZRimpuGX_pYzNbiOU2SkSvJ1GWHIL23xPdYmWwvTQB-ILCoJYoh70NOtXpfEtElSC6BpYCobwIU0UPvrcnCGzBYKm_858yuavV5_MDMU4oon_RJDmKjLUD5qRT1gnasHU5LCn8jiKXd5it9d6094NrJIzylI8Eg_5RKQEAvAYgcpghPAiDbkviHP6ow45SxIf-WHLsJQC40',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDHm1UQ5F_wRPby9-hDdWQs_uXtOHYlsYFdcPW6_bDw9X8R4wemCXhl1VoYUP9wWWPxMozrMFwOkZmpB3HI5UjbK0oOqxzj1SKXw0BoMjeVA4mlQzFDS6kYEu6OMZRvhyXWkhp9sdQrp_hVkl0rAxiUneOdDh-dNjcoCcoH_DW58VGP4BrFqUPrnkSuyAkC5ej7JnIcmyqNvYRCFlE9pwPr_ekBX8mfvcXoBGeAfQjtQ0r7Sq5wiYZ86DZ9GjZCk4YfsopSyOWezoxp',
        ],
        'extraStudents': 12,
      },
      {
        'time': '01:00 PM - 02:00 PM',
        'title': 'World History',
        'grade': 'Grade 11',
        'room': 'Room B2',
        'type': 'history',
        'students': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAaP9EM2I4_X1WhDUyTuVj_ub_3_zXmCDPkKi0eIorLuVX16NnxeP3g899QhXdAv-Si5iYpvpbNhdYOaxLVqjtQMYmwSNC8PxesfSN4Pzt9Cpm7uADwlN83Se7sNs1qUAlYc3vaS7cuvr3h7q8-T3iKWFZhsZHR7gn8UJvRbtuox5yhW4XH2DyMfWHsKUC3JRugKaYwaefpComPYs_neoKy7U9kGmqfIeXibnjwQfBVm7yCmq0JZohPsPPOn8psimxwM-Advfhf3D3P',
        ],
        'extraStudents': 8,
      }
    ]);

    recentActivities.assignAll([
      {
        'title': 'New Student registered for Physics 101',
        'time': '10 mins ago',
        'icon': 'person_add',
        'color': 'primary',
      },
      {
        'title': 'Fee Received from Sarah Jenkins',
        'time': '2 hours ago',
        'icon': 'payments',
        'color': 'secondary',
      },
      {
        'title': 'Low Attendance alert for Grade 10 Math',
        'time': 'Yesterday',
        'icon': 'warning',
        'color': 'error',
      }
    ]);
  }

  Future<void> _fetchLiveKpis() async {
    try {
      final studentSnap = await _firestore.collection(FirebasePaths.students).count().get();
      final count = studentSnap.count;
      if (count != null && count != 0) {
        totalStudents.value = count;
      }
    } catch (_) {}
  }

  Future<void> _fetchLiveUpcomingClasses() async {
    // Live timetable query goes here
  }

  void _listenToRecentActivities() {
    _activitiesSubscription?.cancel();
    _activitiesSubscription = _firestore
        .collection(FirebasePaths.activityLogs)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots()
        .listen((querySnap) {
      if (querySnap.docs.isNotEmpty) {
        final list = querySnap.docs.map((doc) {
          final data = doc.data();
          return {
            'title': data['description'] ?? 'Activity logged',
            'time': data['timestamp'] != null 
                ? (data['timestamp'] as Timestamp).toDate().toIso8601String()
                : 'Recent',
            'icon': 'history',
            'color': 'primary',
          };
        }).toList();
        recentActivities.assignAll(list);
      }
    }, onError: (e) {
      Logger.error('Failed to stream recent activities', e);
    });
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }
}
