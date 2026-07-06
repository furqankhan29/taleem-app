import 'package:get/get.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/student_repository.dart';
import 'package:taleem/modules/students/controllers/student_detail_controller.dart';
import 'package:taleem/modules/students/controllers/student_list_controller.dart';
import 'package:taleem/modules/students/controllers/student_form_controller.dart';

class StudentBinding extends Bindings {
  @override
  void dependencies() {
    // Inject Repository if not already registered (usually registered globally or per binding)
    if (!Get.isRegistered<StudentRepository>()) {
      Get.lazyPut<StudentRepository>(
        () => StudentRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<StudentListController>(() => StudentListController());
    Get.lazyPut<StudentDetailController>(() => StudentDetailController());
    Get.lazyPut<StudentFormController>(() => StudentFormController());
  }
}
