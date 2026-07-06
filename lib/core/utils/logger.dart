import 'dart:developer' as dev;

class Logger {
  Logger._();

  // ANSI escape codes for coloring output
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';

  static void info(String message) {
    _log('$_blue[INFO] $message$_reset');
  }

  static void success(String message) {
    _log('$_green[SUCCESS] $message$_reset');
  }

  static void warning(String message) {
    _log('$_yellow[WARNING] $message$_reset');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('$_red[ERROR] $message$_reset');
    if (error != null) {
      _log('${_red}Details: $error$_reset');
    }
    if (stackTrace != null) {
      _log('${_red}StackTrace:\n$stackTrace$_reset');
    }
  }

  static void _log(String message) {
    dev.log(message, name: 'Taleem');
  }
}
