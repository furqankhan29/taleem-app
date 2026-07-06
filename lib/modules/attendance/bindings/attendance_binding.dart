import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/attendance_repository.dart';
import 'package:taleem/modules/attendance/controllers/attendance_mark_controller.dart';
import 'package:taleem/modules/attendance/controllers/attendance_history_controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // Inject Repository if not already registered
    if (!Get.isRegistered<AttendanceRepository>()) {
      Get.lazyPut<AttendanceRepository>(
        () => AttendanceRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<AttendanceMarkController>(() => AttendanceMarkController());
    Get.lazyPut<AttendanceHistoryController>(() => AttendanceHistoryController());
  }
}
