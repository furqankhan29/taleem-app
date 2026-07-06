import 'package:get/get.dart';
import 'package:taleem/core/services/ai_service.dart';
import 'package:taleem/core/utils/logger.dart';

class AISuggestionController extends GetxController {
  final BaseAIService _aiService = Get.find<BaseAIService>();

  final RxString currentInsight = ''.obs;
  final RxBool isLoadingInsight = false.obs;
  final RxList<Map<String, dynamic>> quickActions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshInsight();
    _loadQuickActions();
  }

  Future<void> refreshInsight() async {
    isLoadingInsight.value = true;
    try {
      final insight = await _aiService.getDashboardInsight();
      currentInsight.value = insight;
    } catch (e) {
      Logger.error('Failed to load AI insight', e);
      currentInsight.value = 'AI insights temporarily unavailable.';
    } finally {
      isLoadingInsight.value = false;
    }
  }

  void _loadQuickActions() {
    quickActions.assignAll([
      {
        'title': 'Generate Report',
        'subtitle': 'Monthly summary',
        'icon': 'description',
        'route': '/ai-assistant',
      },
      {
        'title': 'Draft Reminders',
        'subtitle': 'WhatsApp messages',
        'icon': 'notifications',
        'route': '/whatsapp',
      },
      {
        'title': 'Analytics',
        'subtitle': 'View trends',
        'icon': 'analytics',
        'route': '/ai-assistant',
      },
    ]);
  }

  String get insight => currentInsight.value;
  bool get isLoading => isLoadingInsight.value;
}
