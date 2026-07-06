import 'package:intl/intl.dart';
import 'package:taleem/core/constants/app_constants.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final _currencyFormatShort = NumberFormat.compactCurrency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 1,
  );

  static String toCurrency(double amount, {bool compact = false}) {
    return compact ? _currencyFormatShort.format(amount) : _currencyFormat.format(amount);
  }

  static String formatDate(DateTime date, {String format = AppConstants.dateFormatFull}) {
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormatAmPm).format(date);
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String toCompact(num value) {
    return NumberFormat.compact().format(value);
  }

  static String generateStudentId(int count) {
    final year = DateTime.now().year;
    final idSuffix = count.toString().padLeft(4, '0');
    return 'STU-$year-$idSuffix';
  }

  static String getInitials(String name) {
    if (name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
