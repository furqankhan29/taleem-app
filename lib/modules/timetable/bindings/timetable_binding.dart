import 'package:get/get.dart';
import 'package:taleem/data/repositories/timetable_repository.dart';
import 'package:taleem/modules/timetable/controllers/timetable_controller.dart';

class TimetableBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TimetableRepository>()) {
      Get.lazyPut<TimetableRepository>(() => TimetableRepository(), fenix: true);
    }
    Get.lazyPut<TimetableController>(() => TimetableController());
  }
}
