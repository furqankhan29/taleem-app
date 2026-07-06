import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/services/cache_service.dart';

class SettingsService extends GetxService {
  final CacheService _cache = Get.find<CacheService>();

  static const String _themeKey = 'settings_theme_mode';
  static const String _languageKey = 'settings_language';
  static const String _feeRemindersKey = 'notif_fee_reminders';
  static const String _attendanceAlertsKey = 'notif_attendance_alerts';
  static const String _academicUpdatesKey = 'notif_academic_updates';

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final RxString language = 'en'.obs;
  final RxBool feeReminders = true.obs;
  final RxBool attendanceAlerts = true.obs;
  final RxBool academicUpdates = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final savedTheme = _cache.read<String>(_themeKey);
    if (savedTheme != null) {
      themeMode.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
    language.value = _cache.read<String>(_languageKey) ?? 'en';
    feeReminders.value = _cache.read<bool>(_feeRemindersKey) ?? true;
    attendanceAlerts.value = _cache.read<bool>(_attendanceAlertsKey) ?? true;
    academicUpdates.value = _cache.read<bool>(_academicUpdatesKey) ?? true;
  }

  Future<void> toggleTheme() async {
    themeMode.value =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
    await _cache.write(
        _themeKey, themeMode.value == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _cache.write(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    await _cache.write(_languageKey, lang);
    Get.updateLocale(Locale(lang));
  }

  Map<String, bool> getNotificationPrefs() => {
        'feeReminders': feeReminders.value,
        'attendanceAlerts': attendanceAlerts.value,
        'academicUpdates': academicUpdates.value,
      };

  Future<void> setNotificationPrefs({
    bool? feeReminders,
    bool? attendanceAlerts,
    bool? academicUpdates,
  }) async {
    if (feeReminders != null) {
      this.feeReminders.value = feeReminders;
      await _cache.write(_feeRemindersKey, feeReminders);
    }
    if (attendanceAlerts != null) {
      this.attendanceAlerts.value = attendanceAlerts;
      await _cache.write(_attendanceAlertsKey, attendanceAlerts);
    }
    if (academicUpdates != null) {
      this.academicUpdates.value = academicUpdates;
      await _cache.write(_academicUpdatesKey, academicUpdates);
    }
  }

  Future<String> getCacheSize() async {
    return '12.5 MB';
  }

  Future<void> clearCache() async {
    await _cache.clear();
  }
}
