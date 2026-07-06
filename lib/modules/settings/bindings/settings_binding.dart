import 'package:get/get.dart';
import 'package:taleem/core/services/settings_service.dart';
import 'package:taleem/modules/settings/controllers/profile_controller.dart';
import 'package:taleem/modules/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsService>(() => SettingsService());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
