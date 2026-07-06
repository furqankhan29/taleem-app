import 'package:flutter/material.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/core/utils/helpers.dart';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool isValidEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  bool isValidPhone() {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[\s-()]+'), ''));
  }

  Color toColor() {
    final hexString = replaceAll('#', '');
    if (hexString.length == 6) {
      return Color(int.parse('FF$hexString', radix: 16));
    } else if (hexString.length == 8) {
      return Color(int.parse(hexString, radix: 16));
    }
    return Colors.black;
  }
}

extension DateTimeExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  String formatted({String? format}) {
    if (format != null) {
      return Formatters.formatDate(this, format: format);
    }
    return Formatters.formatDate(this);
  }

  String timeAgo() {
    return Helpers.getTimeAgo(this);
  }
}

extension BuildContextExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  bool get isMobile => width < 768.0;
  bool get isTablet => width >= 768.0 && width <= 1024.0;
  bool get isDesktop => width > 1024.0;
}

extension ListExtensions<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}

extension NumExtensions on num {
  String toCurrency({bool compact = false}) {
    return Formatters.toCurrency(toDouble(), compact: compact);
  }

  String toCompact() {
    return Formatters.toCompact(this);
  }
}
