import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/subject_repository.dart';
import 'package:taleem/modules/subjects/controllers/subject_controller.dart';

class SubjectBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SubjectRepository>()) {
      Get.lazyPut<SubjectRepository>(
        () => SubjectRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<SubjectController>(() => SubjectController());
  }
}
