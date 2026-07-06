import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/extensions.dart';
import 'package:taleem/modules/ai/controllers/ai_chat_controller.dart';
import 'package:taleem/modules/ai/controllers/ai_history_controller.dart';
import 'package:taleem/modules/ai/views/widgets/ai_attachment_picker.dart';
import 'package:taleem/modules/ai/views/widgets/chat_bubble.dart';
import 'package:taleem/modules/ai/views/widgets/suggested_prompts.dart';
import 'package:taleem/modules/ai/views/widgets/typing_indicator.dart';
import 'package:taleem/modules/ai/views/widgets/voice_input_button.dart';
import 'package:taleem/shared/widgets/custom_app_bar.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/side_navigation_drawer.dart';

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AIChatController());
    final historyController = Get.put(AIHistoryController());

    return Scaffold(
      appBar: context.isDesktop ? null : CustomAppBar(
        title: 'AI Assistant',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
            onPressed: () => Get.to(() => const AIHistoryScreen()),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: (context) => _buildMobileLayout(context, controller),
        desktop: (context) => _buildDesktopLayout(context, controller, historyController),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AIChatController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty && !controller.isTyping.value) {
              return _buildEmptyState(context, controller);
            }

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return const TypingIndicator(isTyping: true);
                  }
                  final msg = controller.messages[index];
                  return ChatBubble(
                    message: msg,
                    isLast: index == controller.messages.length - 1,
                  );
                },
              ),
            );
          }),
        ),
        Obx(() => SuggestedPrompts(
          prompts: controller.suggestedPrompts,
          onTap: (prompt) => controller.sendSuggestedPrompt(prompt),
        )),
        _buildInputBar(context, controller, isDark),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AIChatController controller, AIHistoryController historyController) {
    return Row(
      children: [
        const SideNavigationDrawer(currentRoute: '/ai-assistant'),
        Expanded(
          flex: 3,
          child: _buildDesktopChat(context, controller),
        ),
        Container(
          width: 1.0,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.outlineVariantDark
              : AppColors.outlineVariant,
        ),
        Expanded(
          flex: 1,
          child: _buildDesktopHistory(context, historyController, controller),
        ),
      ],
    );
  }

  Widget _buildDesktopChat(BuildContext context, AIChatController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Text(
            'AI Assistant',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty && !controller.isTyping.value) {
              return _buildEmptyState(context, controller);
            }

            return ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.messages.length) {
                  return const TypingIndicator(isTyping: true);
                }
                final msg = controller.messages[index];
                return ChatBubble(
                  message: msg,
                  isLast: index == controller.messages.length - 1,
                );
              },
            );
          }),
        ),
        Obx(() => SuggestedPrompts(
          prompts: controller.suggestedPrompts,
          onTap: (prompt) => controller.sendSuggestedPrompt(prompt),
        )),
        _buildInputBar(context, controller, isDark),
      ],
    );
  }

  Widget _buildDesktopHistory(BuildContext context, AIHistoryController historyController, AIChatController chatController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Text(
            'Conversations',
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (historyController.filteredConversations.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'No History',
                subtitle: 'Start a conversation to see it here.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: historyController.filteredConversations.length,
              itemBuilder: (context, index) {
                final conv = historyController.filteredConversations[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    conv.isPinned ? Icons.push_pin_rounded : Icons.chat_rounded,
                    color: conv.isPinned ? AppColors.primary : AppColors.outline,
                    size: 20.0,
                  ),
                  title: Text(
                    conv.title,
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: conv.lastMessagePreview != null
                      ? Text(
                          conv.lastMessagePreview!,
                          style: AppTypography.labelCaps.copyWith(fontSize: 10.0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onTap: () {
                    chatController.selectConversation(conv.id);
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AIChatController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 40.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Taleem AI Assistant',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Ask me anything about your tuition center.\nAttendance, fees, students, reports and more.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            Obx(() => Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: controller.suggestedPrompts.take(4).map((p) {
                return ActionChip(
                  label: Text(p['title'] as String? ?? ''),
                  onPressed: () => controller.sendSuggestedPrompt(p['title'] as String? ?? ''),
                  backgroundColor: AppColors.primaryFixed,
                  labelStyle: AppTypography.labelCaps.copyWith(color: AppColors.primary),
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, AIChatController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 8.0,
        bottom: MediaQuery.of(context).padding.bottom + 8.0,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerLowDark.withValues(alpha: 0.8)
            : AppColors.surfaceGlass,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0x1BFFFFFF) : const Color(0x1A000000),
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AIAttachmentPicker(
                isEnabled: !controller.isTyping.value,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceContainerHighDark
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: (isDark ? AppColors.outlineVariantDark : AppColors.outlineVariant).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.textController,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Ask Taleem AI anything...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: isDark ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.5) : AppColors.outline,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          ),
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                          ),
                          onSubmitted: (value) => controller.sendMessage(value),
                        ),
                      ),
                      VoiceInputButton(
                        isListening: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: controller.isTyping.value
                      ? AppColors.outline
                      : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (controller.isTyping.value ? AppColors.outline : AppColors.primary).withValues(alpha: 0.3),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    controller.isTyping.value ? Icons.stop_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  onPressed: controller.isTyping.value
                      ? null
                      : () => controller.sendMessage(controller.textController.text),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class AIHistoryScreen extends StatelessWidget {
  const AIHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AIHistoryController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Conversation History',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceContainerLowDark
                    : AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => controller.updateSearch(value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.filteredConversations.isEmpty) {
                return const EmptyState(
                  icon: Icons.history_rounded,
                  title: 'No Conversations',
                  subtitle: 'Start chatting with the AI Assistant to see history.',
                );
              }

              final pinned = controller.pinnedConversations;
              final recent = controller.recentConversations;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  if (pinned.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Pinned',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    ...pinned.map((conv) => _ConversationTile(conversation: conv)),
                    const SizedBox(height: 8.0),
                  ],
                  if (recent.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Recent',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ...recent.map((conv) => _ConversationTile(conversation: conv)),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final dynamic conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AIHistoryController>();
    final chatController = Get.find<AIChatController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      onTap: () {
        chatController.selectConversation(conversation.id);
        Get.back();
      },
      child: Row(
        children: [
          Icon(
            conversation.isPinned ? Icons.push_pin_rounded : Icons.chat_rounded,
            color: conversation.isPinned ? AppColors.primary : AppColors.outline,
            size: 20.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (conversation.lastMessagePreview != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    conversation.lastMessagePreview,
                    style: AppTypography.labelCaps.copyWith(
                      fontSize: 10.0,
                      color: isDark ? AppColors.onSurfaceVariantDark : AppColors.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2.0),
                Text(
                  conversation.updatedAt.timeAgo(),
                  style: AppTypography.labelCaps.copyWith(
                    fontSize: 9.0,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'pin') {
                await controller.togglePin(conversation.id, !conversation.isPinned);
              } else if (value == 'delete') {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete Conversation'),
                    content: const Text('Are you sure? This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteConversation(conversation.id);
                        },
                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(
                      conversation.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                      size: 18.0,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8.0),
                    Text(conversation.isPinned ? 'Unpin' : 'Pin'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18.0, color: AppColors.error),
                    SizedBox(width: 8.0),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
