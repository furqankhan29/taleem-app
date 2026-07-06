import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/exam_repository.dart';
import 'package:taleem/modules/exams/controllers/exam_controller.dart';

class ExamBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ExamRepository>()) {
      Get.lazyPut<ExamRepository>(
        () => ExamRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<ExamController>(() => ExamController());
  }
}
