import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/notification_model.dart';
import 'package:taleem/data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = Get.find<NotificationRepository>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadCount = 0.obs;
  final RxBool hasMore = true.obs;

  final int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    _subscribeUnreadCount();
  }

  void _subscribeUnreadCount() {
    _repository.streamUnreadCount().listen((count) {
      unreadCount.value = count;
    });
  }

  Future<void> loadNotifications({String? userId, String? role}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getNotifications(
        userId: userId,
        role: role,
        limit: _pageSize,
      );
      notifications.assignAll(data);
      hasMore.value = data.length >= _pageSize;
    } catch (e) {
      errorMessage.value = ErrorHandler.handleError(e).message;
      Helpers.showSnackbar(title: 'Error', message: errorMessage.value, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore({String? userId, String? role}) async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final lastDoc = await _repository.getNotifications(
        userId: userId,
        role: role,
        limit: 1,
      );
      if (lastDoc.isEmpty) {
        hasMore.value = false;
        return;
      }
      final more = await _repository.getNotifications(
        userId: userId,
        role: role,
        limit: _pageSize,
      );
      if (more.length < _pageSize) hasMore.value = false;
      notifications.addAll(more);
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final idx = notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        notifications[idx] = notifications[idx].copyWith(isRead: true);
      }
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> markAllAsRead({String? userId}) async {
    try {
      await _repository.markAllAsRead(userId: userId);
      notifications.assignAll(notifications.map((n) => n.copyWith(isRead: true)));
      Helpers.showSnackbar(title: 'Success', message: 'All marked as read');
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.delete(id);
      notifications.removeWhere((n) => n.id == id);
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }
}
