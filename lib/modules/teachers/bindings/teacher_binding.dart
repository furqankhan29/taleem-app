import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/teacher_repository.dart';
import 'package:taleem/modules/teachers/controllers/teacher_controller.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TeacherRepository>()) {
      Get.lazyPut<TeacherRepository>(
        () => TeacherRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<TeacherController>(() => TeacherController());
  }
}
