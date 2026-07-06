class AppConstants {
  AppConstants._();

  static const String appName = 'Taleem';
  static const String appVersion = '1.0.4';
  
  // Cache keys
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyAuthToken = 'auth_token';
  static const String keyCurrentUser = 'current_user';
  static const String keyOfflineSyncQueue = 'offline_sync_queue';

  // Config constants
  static const int paginationLimit = 20;

  // Regional format configurations
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';
  
  // Date and Time formats
  static const String dateFormatFull = 'MMMM dd, yyyy';
  static const String dateFormatShort = 'MMM dd, yyyy';
  static const String dateFormatDayMonth = 'EEE, MMM dd';
  static const String timeFormatAmPm = 'hh:mm a';
}
