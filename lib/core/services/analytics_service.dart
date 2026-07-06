import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:taleem/core/utils/logger.dart';

class AnalyticsService extends GetxService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalytics get analytics => _analytics;

  Future<void> init() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      Logger.success('Analytics initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Analytics', e);
    }
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters?.cast<String, Object>(),
      );
    } catch (e) {
      Logger.error('Failed to log analytics event: $name', e);
    }
  }

  Future<void> logScreen(String screenName) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );
    } catch (e) {
      Logger.error('Failed to log screen view: $screenName', e);
    }
  }

  Future<void> logAction({
    required String action,
    required String category,
    String? label,
  }) async {
    try {
      await _analytics.logEvent(
        name: action,
        parameters: {
          'category': category,
          if (label != null) 'label': label,
        },
      );
    } catch (e) {
      Logger.error('Failed to log action: $action', e);
    }
  }
}
