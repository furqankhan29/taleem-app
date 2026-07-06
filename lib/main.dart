import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taleem/app/app.dart';
import 'package:taleem/core/services/cache_service.dart';
import 'package:taleem/core/services/firebase_service.dart';
import 'package:taleem/core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style (transparent status bar, navigation bar settings)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Restrict screen orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise Local Storage (Hive Box)
  final cacheService = CacheService();
  await cacheService.init();
  Get.put<CacheService>(cacheService, permanent: true);

  // Initialise Firebase
  await FirebaseService.init();

  // Handle Flutter global errors
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error('Flutter global error caught', details.exception, details.stack);
  };

  runApp(const TaleemApp());
}
