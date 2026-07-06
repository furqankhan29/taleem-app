import 'package:get/get.dart';
import 'package:taleem/core/services/ai_service.dart';
import 'package:taleem/core/services/local_ai_service.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/ai_repository.dart';
import 'package:taleem/modules/ai/controllers/ai_chat_controller.dart';
import 'package:taleem/modules/ai/controllers/ai_history_controller.dart';
import 'package:taleem/modules/ai/controllers/ai_suggestion_controller.dart';

class AIBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AIRepository>()) {
      Get.lazyPut<AIRepository>(
        () => AIRepository(firebaseProvider: Get.find<FirebaseProvider>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<BaseAIService>()) {
      Get.lazyPut<BaseAIService>(() => LocalAIService(), fenix: true);
    }

    Get.lazyPut<AIChatController>(() => AIChatController());
    Get.lazyPut<AIHistoryController>(() => AIHistoryController());
    Get.lazyPut<AISuggestionController>(() => AISuggestionController());
  }
}
