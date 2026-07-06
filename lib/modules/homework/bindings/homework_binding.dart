import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/homework_repository.dart';
import 'package:taleem/modules/homework/controllers/homework_controller.dart';

class HomeworkBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeworkRepository>()) {
      Get.lazyPut<HomeworkRepository>(
        () => HomeworkRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<HomeworkController>(() => HomeworkController());
  }
}
