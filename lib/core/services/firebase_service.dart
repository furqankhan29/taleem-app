import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/firebase_options.dart';
import 'package:taleem/core/services/app_check_service.dart';
import 'package:taleem/core/services/crashlytics_service.dart';
import 'package:taleem/core/services/analytics_service.dart';
import 'package:taleem/core/services/remote_config_service.dart';
import 'package:taleem/core/utils/logger.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> init() async {
    try {
      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Logger.success('Firebase Core initialized successfully');

      // Enable Firestore offline persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
      Logger.success('Firestore offline persistence configured');

      // Initialize App Check
      final appCheckService = Get.put<AppCheckService>(AppCheckService(), permanent: true);
      await appCheckService.init();

      // Initialize Crashlytics
      final crashlyticsService = Get.put<CrashlyticsService>(CrashlyticsService(), permanent: true);
      await crashlyticsService.init();

      // Initialize Analytics
      final analyticsService = Get.put<AnalyticsService>(AnalyticsService(), permanent: true);
      await analyticsService.init();

      // Initialize Remote Config
      final remoteConfigService = Get.put<RemoteConfigService>(RemoteConfigService(), permanent: true);
      await remoteConfigService.init();

      Logger.success('All Firebase sub-services initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Firebase services. The app will run in local-only fallback mode.', e);
    }
  }
}

