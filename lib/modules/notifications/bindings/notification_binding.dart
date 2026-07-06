import 'package:get/get.dart';
import 'package:taleem/data/repositories/notification_repository.dart';
import 'package:taleem/modules/notifications/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationRepository>()) {
      Get.lazyPut<NotificationRepository>(() => NotificationRepository(), fenix: true);
    }
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
