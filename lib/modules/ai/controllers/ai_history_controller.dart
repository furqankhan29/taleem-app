import 'package:get/get.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/ai_conversation_model.dart';
import 'package:taleem/data/repositories/ai_repository.dart';
import 'package:taleem/modules/auth/controllers/auth_controller.dart';

class AIHistoryController extends GetxController {
  final AIRepository _repository = Get.find<AIRepository>();

  final RxList<AIConversation> conversations = <AIConversation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<AIConversation> filteredConversations = <AIConversation>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadConversations();
  }

  void _loadConversations() {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.id ?? 'default_user';
    _repository.streamConversations(userId).listen((list) {
      conversations.assignAll(list);
      _applyFilter();
    });
  }

  void _applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredConversations.assignAll(conversations);
    } else {
      filteredConversations.assignAll(
        conversations.where((c) =>
            c.title.toLowerCase().contains(query) ||
            (c.lastMessagePreview?.toLowerCase().contains(query) ?? false)),
      );
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  List<AIConversation> get pinnedConversations =>
      filteredConversations.where((c) => c.isPinned).toList();

  List<AIConversation> get recentConversations =>
      filteredConversations.where((c) => !c.isPinned).toList();

  Future<void> togglePin(String id, bool isPinned) async {
    await _repository.togglePinConversation(id, isPinned);
    Helpers.showSnackbar(
      title: isPinned ? 'Pinned' : 'Unpinned',
      message: isPinned ? 'Conversation pinned to top' : 'Conversation unpinned',
    );
  }

  Future<void> deleteConversation(String id) async {
    await _repository.deleteConversation(id);
    Helpers.showSnackbar(
      title: 'Deleted',
      message: 'Conversation removed',
    );
  }

  Future<void> renameConversation(String id, String newTitle) async {
    final conv = conversations.firstWhereOrNull((c) => c.id == id);
    if (conv != null) {
      final updated = conv.copyWith(title: newTitle, updatedAt: DateTime.now());
      await _repository.updateConversation(updated);
    }
  }
}
