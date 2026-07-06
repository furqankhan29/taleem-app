import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/fee_repository.dart';
import 'package:taleem/modules/fees/controllers/fee_controller.dart';
import 'package:taleem/modules/fees/controllers/fee_collect_controller.dart';

class FeeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FeeRepository>()) {
      Get.lazyPut<FeeRepository>(
        () => FeeRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<FeeController>(() => FeeController());
    Get.lazyPut<FeeCollectController>(() => FeeCollectController());
  }
}
