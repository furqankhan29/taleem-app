import 'package:get/get.dart';
import 'package:taleem/core/network/connectivity_service.dart';
import 'package:taleem/core/services/ai_service.dart';
import 'package:taleem/core/services/analytics_service.dart';
import 'package:taleem/core/services/app_check_service.dart';
import 'package:taleem/core/services/auth_service.dart';
import 'package:taleem/core/services/cache_service.dart';
import 'package:taleem/core/services/crashlytics_service.dart';
import 'package:taleem/core/services/export_service.dart';
import 'package:taleem/core/services/local_ai_service.dart';
import 'package:taleem/core/services/local_report_service.dart';
import 'package:taleem/core/services/remote_config_service.dart';
import 'package:taleem/core/services/report_service.dart';
import 'package:taleem/core/services/session_service.dart';
import 'package:taleem/core/services/sync_service.dart';
import 'package:taleem/core/services/storage_service.dart';
import 'package:taleem/core/services/push_notification_service.dart';
import 'package:taleem/data/providers/firebase_provider.dart';
import 'package:taleem/data/repositories/ai_repository.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Inject Firebase Provider
    Get.put<FirebaseProvider>(FirebaseProvider(), permanent: true);

    // Inject Storage Service
    Get.put<StorageService>(StorageService(), permanent: true);

    // Inject Connectivity Service
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    
    // Inject Cache Service (Hive)
    Get.put<CacheService>(CacheService(), permanent: true);
    
    // Inject Sync Service for Offline queue
    Get.put<SyncService>(SyncService(), permanent: true);

    // Inject AI Service
    Get.put<BaseAIService>(LocalAIService(), permanent: true);

    // Inject Report Service
    Get.put<BaseReportService>(LocalReportService(), permanent: true);

    // Inject Export Service
    Get.put<ExportService>(ExportService(), permanent: true);

    // Inject AI Repository
    Get.put<AIRepository>(
      AIRepository(firebaseProvider: Get.find<FirebaseProvider>()),
      permanent: true,
    );

    // Inject Auth Service
    Get.put<AuthService>(AuthService(), permanent: true);

    // Inject Push Notification Service
    final pushNotificationService = Get.put<PushNotificationService>(PushNotificationService(), permanent: true);
    pushNotificationService.init();

    // Inject Session Service
    Get.put<SessionService>(SessionService(), permanent: true);

    // Inject Crashlytics Service
    Get.put<CrashlyticsService>(CrashlyticsService(), permanent: true);

    // Inject Analytics Service
    Get.put<AnalyticsService>(AnalyticsService(), permanent: true);

    // Inject App Check Service
    Get.put<AppCheckService>(AppCheckService(), permanent: true);

    // Inject Remote Config Service
    Get.put<RemoteConfigService>(RemoteConfigService(), permanent: true);
  }
}
