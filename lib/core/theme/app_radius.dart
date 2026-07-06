import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double regular = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;

  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderRegular => BorderRadius.circular(regular);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderFull => BorderRadius.circular(full);
}
