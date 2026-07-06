import 'package:get/get.dart';
import 'package:taleem/data/repositories/calendar_repository.dart';
import 'package:taleem/modules/calendar/controllers/calendar_controller.dart';

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CalendarRepository>()) {
      Get.lazyPut<CalendarRepository>(() => CalendarRepository(), fenix: true);
    }
    Get.lazyPut<CalendarController>(() => CalendarController());
  }
}
