import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:taleem/core/utils/logger.dart';

class RemoteConfigService extends GetxService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const Map<String, dynamic> _defaultValues = {
    'maintenance_mode': false,
    'min_app_version': '1.0.0',
    'force_update': false,
    'api_base_url': '',
    'max_upload_size_mb': 10,
    'enable_ai_features': true,
    'default_theme': 'light',
  };

  Future<void> init() async {
    try {
      await _remoteConfig.setDefaults(_defaultValues);

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig.fetchAndActivate();

      Logger.success('Remote Config initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Remote Config', e);
    }
  }

  String getString(String key) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      Logger.error('Failed to get string config: $key', e);
      return _defaultValues[key] as String? ?? '';
    }
  }

  int getInt(String key) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      Logger.error('Failed to get int config: $key', e);
      return _defaultValues[key] as int? ?? 0;
    }
  }

  bool getBool(String key) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      Logger.error('Failed to get bool config: $key', e);
      return _defaultValues[key] as bool? ?? false;
    }
  }

  double getDouble(String key) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (e) {
      Logger.error('Failed to get double config: $key', e);
      return _defaultValues[key] as double? ?? 0.0;
    }
  }

  Future<bool> fetchConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
      Logger.info('Remote Config fetched and activated');
      return true;
    } catch (e) {
      Logger.error('Failed to fetch Remote Config', e);
      return false;
    }
  }
}
