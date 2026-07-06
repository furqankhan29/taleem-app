import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/notification_model.dart';
import 'package:taleem/modules/notifications/controllers/notification_controller.dart';
import 'package:taleem/modules/notifications/views/widgets/notification_tile.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/error_state.dart';
import 'package:taleem/shared/widgets/shimmer_loading.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          Obx(() => controller.unreadCount > 0
              ? TextButton(
                  onPressed: () => controller.markAllAsRead(),
                  child: Text(
                    'Mark all read (${controller.unreadCount})',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                  ),
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoading();
        if (controller.errorMessage.isNotEmpty) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadNotifications(),
          );
        }
        if (controller.notifications.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_off_outlined,
            title: 'No Notifications',
            subtitle: 'You\'re all caught up!',
          );
        }
        return _buildList();
      }),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ShimmerLoading(width: 40, height: 40, borderRadius: 10),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 200, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () => controller.loadNotifications(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            controller.loadMore();
          }
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.notifications.length,
                itemBuilder: (_, i) {
                  final notification = controller.notifications[i];
                  return NotificationTile(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        controller.markAsRead(notification.id);
                      }
                      _showNotificationDetail(notification);
                    },
                    onDelete: () => controller.deleteNotification(notification.id),
                  );
                },
              ),
            ),
            Obx(() => controller.isLoadingMore.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const SizedBox()),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(NotificationModel notification) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _typeIcon(notification.type),
                  const SizedBox(width: 8),
                  Text(
                    notification.type.name.toUpperCase(),
                    style: AppTypography.labelCaps.copyWith(color: _typeColor(notification.type)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(notification.title, style: AppTypography.headlineMedium),
              const SizedBox(height: 8),
              Text(notification.body, style: AppTypography.bodyMedium),
              const SizedBox(height: 16),
              Text(
                DateFormat('MMM d, yyyy – h:mm a').format(notification.createdAt),
                style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeIcon(NotificationType type) {
    IconData icon;
    switch (type) {
      case NotificationType.fee:
        icon = Icons.payments;
      case NotificationType.attendance:
        icon = Icons.fact_check;
      case NotificationType.academic:
        icon = Icons.school;
      case NotificationType.general:
        icon = Icons.notifications;
      case NotificationType.system:
        icon = Icons.settings;
    }
    return Icon(icon, size: 20, color: _typeColor(type));
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.fee:
        return Colors.green;
      case NotificationType.attendance:
        return Colors.orange;
      case NotificationType.academic:
        return Colors.blue;
      case NotificationType.general:
        return AppColors.primary;
      case NotificationType.system:
        return Colors.grey;
    }
  }
}
