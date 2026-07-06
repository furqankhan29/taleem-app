import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = Get.find<SettingsService>();

  ThemeMode get themeMode => _settingsService.themeMode.value;
  String get language => _settingsService.language.value;
  bool get feeReminders => _settingsService.feeReminders.value;
  bool get attendanceAlerts => _settingsService.attendanceAlerts.value;
  bool get academicUpdates => _settingsService.academicUpdates.value;

  Future<void> toggleTheme() => _settingsService.toggleTheme();
  Future<void> setThemeMode(ThemeMode mode) =>
      _settingsService.setThemeMode(mode);

  Future<void> setLanguage(String lang) => _settingsService.setLanguage(lang);

  Future<void> setNotificationPrefs({
    bool? feeReminders,
    bool? attendanceAlerts,
    bool? academicUpdates,
  }) =>
      _settingsService.setNotificationPrefs(
        feeReminders: feeReminders,
        attendanceAlerts: attendanceAlerts,
        academicUpdates: academicUpdates,
      );

  Future<String> getCacheSize() => _settingsService.getCacheSize();
  Future<void> clearCache() => _settingsService.clearCache();
}
