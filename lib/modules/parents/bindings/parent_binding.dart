import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/parent_repository.dart';
import 'package:taleem/modules/parents/controllers/parent_controller.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ParentRepository>()) {
      Get.lazyPut<ParentRepository>(
        () => ParentRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<ParentController>(() => ParentController());
  }
}
