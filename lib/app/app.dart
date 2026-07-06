import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_pages.dart';
import 'package:taleem/core/theme/app_theme.dart';
import 'package:taleem/modules/settings/controllers/theme_controller.dart';
import 'package:taleem/app/app_bindings.dart';

class TaleemApp extends StatelessWidget {
  const TaleemApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return Obx(() => GetMaterialApp(
          title: 'Taleem',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: AppPages.initial,
          getPages: AppPages.pages,
          initialBinding: AppBindings(),
          defaultTransition: Transition.fadeIn,
        ));
  }
}
