import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/extensions.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/modules/whatsapp/controllers/whatsapp_controller.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/side_navigation_drawer.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class WhatsappScreen extends StatefulWidget {
  const WhatsappScreen({super.key});

  @override
  State<WhatsappScreen> createState() => _WhatsappScreenState();
}

class _WhatsappScreenState extends State<WhatsappScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WhatsappController>();

    return Scaffold(
      appBar: context.isDesktop ? null : AppBar(
        title: const Text('WhatsApp Reminder Center'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Suggestions'),
            Tab(text: 'Templates'),
            Tab(text: 'History Logs'),
          ],
        ),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoadingSuggestions.value || controller.isLoadingLogs.value,
            child: ResponsiveLayout(
              mobile: (context) => _buildMobileLayout(context, controller),
              desktop: (context) => _buildDesktopLayout(context, controller),
            ),
          )),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WhatsappController controller) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSuggestionsTab(controller),
        _buildTemplatesTab(controller),
        _buildLogsTab(controller),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WhatsappController controller) {
    return Row(
      children: [
        const SideNavigationDrawer(currentRoute: AppRoutes.whatsappReminders),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Communication Hub',
                      style: AppTypography.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Suggestions'),
                        Tab(text: 'Templates'),
                        Tab(text: 'History Logs'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSuggestionsTab(controller),
                      _buildTemplatesTab(controller),
                      _buildLogsTab(controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsTab(WhatsappController controller) {
    return Obx(() => controller.suggestions.isEmpty
        ? const EmptyState(
            icon: Icons.mark_chat_read_rounded,
            title: 'All Caught Up!',
            subtitle: 'No pending student absence or fee overdue suggestions.',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.suggestions.length,
            itemBuilder: (context, index) {
              final sug = controller.suggestions[index];
              final isAbsence = sug['type'] == 'absence';

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sug['studentName'],
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          StatusChip(
                            label: sug['type'].toString().toUpperCase(),
                            color: isAbsence ? AppColors.secondary : AppColors.tertiary,
                            textColor: isAbsence ? AppColors.secondary : AppColors.tertiary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        sug['details'],
                        style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12.0),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(AppRadius.regular),
                        ),
                        child: Text(
                          sug['message'],
                          style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phone: ${sug['phone']}',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => controller.sendWhatsAppMessage(sug),
                            icon: const Icon(Icons.send_rounded, size: 16.0),
                            label: const Text('Send WhatsApp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ));
  }

  Widget _buildTemplatesTab(WhatsappController controller) {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.templates.length,
          itemBuilder: (context, index) {
            final t = controller.templates[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: GlassCard(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t['name']!,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      t['body']!,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Get.rawSnackbar(
                              title: 'Template Variables',
                              message: 'Variables: {{studentName}}, {{dueDate}}, {{feeAmount}}',
                            );
                          },
                          icon: const Icon(Icons.code_rounded, size: 16.0),
                          label: const Text('Variables Info'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _buildLogsTab(WhatsappController controller) {
    return Obx(() => controller.deliveryLogs.isEmpty
        ? const EmptyState(
            icon: Icons.history_rounded,
            title: 'No Broadcast logs',
            subtitle: 'You have not sent any WhatsApp reminders through the hub yet.',
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.deliveryLogs.length,
            itemBuilder: (context, index) {
              final log = controller.deliveryLogs[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            log.recipientName ?? 'Parent',
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          StatusChip(
                            label: log.status.name,
                            color: Colors.green,
                            textColor: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        log.message,
                        style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'To: ${log.recipientPhone}',
                            style: TextStyle(fontSize: 10.0, color: AppColors.outline),
                          ),
                          Text(
                            Formatters.formatDate(log.scheduledAt),
                            style: TextStyle(fontSize: 10.0, color: AppColors.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ));
  }
}
