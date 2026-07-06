import 'package:get/get.dart';
import 'package:taleem/core/services/whatsapp_service.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/whatsapp_reminder_repository.dart';
import 'package:taleem/modules/whatsapp/controllers/whatsapp_controller.dart';

class WhatsappBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WhatsappReminderRepository>()) {
      Get.lazyPut<WhatsappReminderRepository>(
        () => WhatsappReminderRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<WhatsAppService>()) {
      Get.lazyPut<WhatsAppService>(() => WhatsAppService(), fenix: true);
    }

    Get.lazyPut<WhatsappController>(() => WhatsappController());
  }
}
