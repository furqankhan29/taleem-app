import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:taleem/core/utils/logger.dart';

class AppCheckService extends GetxService {
  Future<void> init() async {
    try {
      if (kDebugMode) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );

        FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

        Logger.info('App Check initialized in debug mode');
      } else {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.deviceCheck,
        );

        FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

        Logger.info('App Check initialized in production mode');
      }
    } catch (e) {
      Logger.error('Failed to initialize App Check', e);
    }
  }

  String? get debugToken {
    try {
      if (kDebugMode) {
        return 'YOUR_DEBUG_TOKEN';
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get debug token', e);
      return null;
    }
  }
}
