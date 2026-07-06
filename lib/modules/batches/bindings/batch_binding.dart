import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/batch_repository.dart';
import 'package:taleem/modules/batches/controllers/batch_controller.dart';

class BatchBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BatchRepository>()) {
      Get.lazyPut<BatchRepository>(
        () => BatchRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<BatchController>(() => BatchController());
  }
}
