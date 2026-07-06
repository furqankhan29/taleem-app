import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // Primary Font - Hanken Grotesk for Headings/Display
  static TextStyle get hankenGrotesk => GoogleFonts.hankenGrotesk();
  
  // Secondary Font - Inter for Body/Labels
  static TextStyle get inter => GoogleFonts.inter();

  // Display Large
  static TextStyle get displayLarge => GoogleFonts.hankenGrotesk(
        fontSize: 48.0,
        fontWeight: FontWeight.w700,
        height: 56.0 / 48.0,
        letterSpacing: -48.0 * 0.02,
      );

  // Display Large Mobile
  static TextStyle get displayLargeMobile => GoogleFonts.hankenGrotesk(
        fontSize: 36.0,
        fontWeight: FontWeight.w700,
        height: 44.0 / 36.0,
        letterSpacing: -36.0 * 0.02,
      );

  // Headline Medium
  static TextStyle get headlineMedium => GoogleFonts.hankenGrotesk(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        height: 32.0 / 24.0,
      );

  // Title Large
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        height: 28.0 / 20.0,
      );

  // Body Medium
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 24.0 / 16.0,
      );

  // Body Small
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 20.0 / 14.0,
      );

  // Label Caps
  static TextStyle get labelCaps => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w700,
        height: 16.0 / 12.0,
        letterSpacing: 12.0 * 0.05,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayLargeMobile,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelCaps,
      );

  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: Colors.white),
        displayMedium: displayLargeMobile.copyWith(color: Colors.white),
        headlineMedium: headlineMedium.copyWith(color: Colors.white),
        titleLarge: titleLarge.copyWith(color: Colors.white),
        bodyMedium: bodyMedium.copyWith(color: Colors.white70),
        bodySmall: bodySmall.copyWith(color: Colors.white70),
        labelLarge: labelCaps.copyWith(color: Colors.white60),
      );
}
