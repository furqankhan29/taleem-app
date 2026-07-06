import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:taleem/core/services/auth_service.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/logger.dart';

class PushNotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // Start listening for user changes to handle tokens and topic subscriptions
    ever(_authService.currentUser, _onUserChanged);
  }

  Future<void> init() async {
    try {
      // 1. Request notification permissions (vital for iOS and Android 13+)
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.success('User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        Logger.info('User granted provisional notification permissions');
      } else {
        Logger.warning('User declined or has not granted notification permissions');
      }

      // 2. Configure Foreground message handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Logger.info('Foreground push notification received: ${message.notification?.title}');
        _showForegroundNotification(message);
      });

      // 3. Configure Background notification click handling
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Logger.info('Push notification clicked in background state: ${message.data}');
        _handleNotificationClick(message);
      });

      // 4. Handle initial message (terminated state click)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        Logger.info('Push notification clicked from terminated state: ${initialMessage.data}');
        _handleNotificationClick(initialMessage);
      }

      // 5. Setup Token Refresh listener
      _fcm.onTokenRefresh.listen((token) async {
        Logger.info('FCM Token refreshed');
        await _updateFcmTokenInFirestore(token);
      });

      // Initialize token for current user if already logged in
      final currentUser = _authService.currentUser.value;
      if (currentUser != null) {
        await registerDeviceForNotifications(currentUser.id);
      }
    } catch (e) {
      Logger.error('Failed to initialize push notification service', e);
    }
  }

  // Monitor user login state changes
  Future<void> _onUserChanged(dynamic user) async {
    if (user != null) {
      // User logged in, register device and subscribe to topics
      await registerDeviceForNotifications(user.id);
      await subscribeUserToTopics(user);
    }
  }

  // Register FCM Token in user's profile
  Future<void> registerDeviceForNotifications(String userId) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _authService.updateFcmToken(token);
        Logger.success('FCM Token successfully registered for user: $userId');
      }
    } catch (e) {
      Logger.error('Failed to retrieve or upload FCM token', e);
    }
  }

  // Deregister FCM Token on logout
  Future<void> deregisterDeviceForNotifications() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _authService.removeFcmToken(token);
      }
      // Unsubscribe from general topics
      await _fcm.unsubscribeFromTopic('all_users');
      final user = _authService.currentUser.value;
      if (user != null) {
        await _fcm.unsubscribeFromTopic('role_${user.role.name}');
      }
      Logger.info('FCM Token and topics unsubscribed successfully');
    } catch (e) {
      Logger.error('Failed to remove token during deregistration', e);
    }
  }

  // Subscribe user to topics based on roles/classes
  Future<void> subscribeUserToTopics(dynamic user) async {
    try {
      // Subscribe to general users topic
      await _fcm.subscribeToTopic('all_users');

      // Subscribe to role-specific topic
      final roleTopic = 'role_${user.role.name}';
      await _fcm.subscribeToTopic(roleTopic);
      Logger.info('Subscribed user to topic: $roleTopic');

      // Subscribe to student batches if applicable
      // Check if user model contains batchIds or dynamic variables
      try {
        if (user.role.name == 'student' && user.batchIds != null) {
          for (final String batchId in user.batchIds) {
            final topic = 'batch_$batchId';
            await _fcm.subscribeToTopic(topic);
            Logger.info('Subscribed student to batch topic: $topic');
          }
        }
      } catch (_) {}
    } catch (e) {
      Logger.error('Failed to subscribe user to topics', e);
    }
  }

  Future<void> _updateFcmTokenInFirestore(String token) async {
    if (_authService.currentUser.value != null) {
      await _authService.updateFcmToken(token);
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    
    // Display premium customized GetX snackbar
    Helpers.showSnackbar(
      title: title,
      message: body,
      isError: false,
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    // Navigate dynamically depending on metadata payload
    final route = message.data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route);
    } else {
      Get.toNamed('/notifications');
    }
  }
}
