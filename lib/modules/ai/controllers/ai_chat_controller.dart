import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/services/ai_service.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/logger.dart';
import 'package:taleem/data/models/ai_chat_message_model.dart';
import 'package:taleem/data/models/ai_conversation_model.dart';
import 'package:taleem/data/repositories/ai_repository.dart';
import 'package:taleem/modules/auth/controllers/auth_controller.dart';

class AIChatController extends GetxController {
  final AIRepository _repository = Get.find<AIRepository>();
  final BaseAIService _aiService = Get.find<BaseAIService>();

  final RxList<AIChatMessage> messages = <AIChatMessage>[].obs;
  final RxString currentConversationId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final RxList<Map<String, dynamic>> suggestedPrompts = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? _currentUserId;

  @override
  void onInit() {
    super.onInit();
    final authCtrl = Get.find<AuthController>();
    _currentUserId = authCtrl.currentUser.value?.id ?? 'default_user';
    _loadSuggestedPrompts();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _loadSuggestedPrompts() async {
    final prompts = await _aiService.getSuggestedPrompts();
    suggestedPrompts.assignAll(prompts);
  }

  Future<void> startNewConversation() async {
    final convId = Helpers.generateUniqueId();
    final conversation = AIConversation(
      id: convId,
      title: 'New Conversation',
      userId: _currentUserId ?? 'default_user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.createConversation(conversation);
    currentConversationId.value = convId;
    messages.clear();

    _loadMessages(convId);
  }

  void selectConversation(String conversationId) {
    currentConversationId.value = conversationId;
    _loadMessages(conversationId);
  }

  void _loadMessages(String conversationId) {
    _repository.streamMessages(conversationId).listen((newMessages) {
      messages.assignAll(newMessages);
    });
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (currentConversationId.value.isEmpty) {
      await startNewConversation();
    }

    final convId = currentConversationId.value;

    final userMessage = AIChatMessage(
      id: Helpers.generateUniqueId(),
      conversationId: convId,
      role: AIMessageRole.user,
      content: trimmed,
      timestamp: DateTime.now(),
    );

    await _repository.saveMessage(userMessage);
    textController.clear();
    isTyping.value = true;

    try {
      final response = await _aiService.generateResponse(
        prompt: trimmed,
        context: messages.toList(),
      );

      final responseMessage = response.copyWith(
        conversationId: convId,
      );

      await _repository.saveMessage(responseMessage);

      await _repository.updateConversation(
        AIConversation(
          id: convId,
          title: messages.length <= 2 ? trimmed : '',
          userId: _currentUserId ?? 'default_user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messageCount: messages.length + 1,
          lastMessagePreview: response.content.length > 100
              ? '${response.content.substring(0, 100)}...'
              : response.content,
        ),
      );

      _scrollToBottom();
    } catch (e) {
      Logger.error('Failed to get AI response', e);
      Helpers.showSnackbar(
        title: 'Error',
        message: 'Failed to get response. Please try again.',
        isError: true,
      );
    } finally {
      isTyping.value = false;
    }
  }

  Future<void> sendSuggestedPrompt(String prompt) async {
    await sendMessage(prompt);
  }

  Future<void> retryLastMessage() async {
    if (messages.length >= 2) {
      final lastUserMsg = messages.lastWhere(
        (m) => m.role == AIMessageRole.user,
        orElse: () => messages.last,
      );
      if (lastUserMsg.role == AIMessageRole.user) {
        await sendMessage(lastUserMsg.content);
      }
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    await _repository.deleteConversation(conversationId);
    if (currentConversationId.value == conversationId) {
      currentConversationId.value = '';
      messages.clear();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> searchMessages(String query) async {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      if (currentConversationId.value.isNotEmpty) {
        _loadMessages(currentConversationId.value);
      }
      return;
    }

    final allMessages = await _repository.getMessages(currentConversationId.value);
    final lower = query.toLowerCase();
    final filtered = allMessages.where((m) =>
        m.content.toLowerCase().contains(lower)).toList();
    messages.assignAll(filtered);
  }
}
