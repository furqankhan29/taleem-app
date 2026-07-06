import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:taleem/core/utils/logger.dart';

class CrashlyticsService extends GetxService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> init() async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      FlutterError.onError = (errorDetails) {
        _crashlytics.recordFlutterError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        _crashlytics.recordError(error, stackTrace, fatal: true);
        return true;
      };

      Logger.success('Crashlytics initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Crashlytics', e);
    }
  }

  Future<void> logError(Object error, StackTrace stackTrace) async {
    try {
      await _crashlytics.recordError(error, stackTrace, fatal: false);
    } catch (e) {
      Logger.error('Failed to log error to Crashlytics', e);
    }
  }

  Future<void> logMessage(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      Logger.error('Failed to log message to Crashlytics', e);
    }
  }

  Future<void> setUserData({
    required String userId,
    required String role,
    required String email,
  }) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      await _crashlytics.setCustomKey('role', role);
      await _crashlytics.setCustomKey('email', email);
    } catch (e) {
      Logger.error('Failed to set Crashlytics user data', e);
    }
  }
}
