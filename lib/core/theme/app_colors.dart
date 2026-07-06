import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Indigo
  static const Color primary = Color(0xFF2C2ABC);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF4648D4);
  static const Color onPrimaryContainer = Color(0xFFD1D1FF);
  static const Color inversePrimary = Color(0xFFC0C1FF);

  // Secondary Cerulean
  static const Color secondary = Color(0xFF006590);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF85CBFD);
  static const Color onSecondaryContainer = Color(0xFF00567C);

  // Tertiary Ruby
  static const Color tertiary = Color(0xFF8E0028);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFB90538);
  static const Color onTertiaryContainer = Color(0xFFFFC7CA);

  // Neutral Colors (Light Theme)
  static const Color background = Color(0xFFFAF8FF);
  static const Color onBackground = Color(0xFF131B2E);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color surfaceVariant = Color(0xFFDAE2FC);
  static const Color onSurfaceVariant = Color(0xFF464554);
  static const Color surfaceDim = Color(0xFFD2D9F4);
  static const Color surfaceBright = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE1E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FC);

  // Outline
  static const Color outline = Color(0xFF767586);
  static const Color outlineVariant = Color(0xFFC6C5D7);

  // Inverse Surface
  static const Color inverseSurface = Color(0xFF283044);
  static const Color inverseOnSurface = Color(0xFFEEF0FF);

  // Semantic & Feedback
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color successContainer = Color(0xFFC9E6FF);
  static const Color warningContainer = Color(0xFFFFDAD6);

  // Glassmorphism and Shadows
  static const Color surfaceGlass = Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.7)
  static const Color surfaceGlassDark = Color(0xB31A1A24); // Dark mode equivalent
  static const Color ambientShadow = Color(0x264648D4); // rgba(70, 72, 212, 0.15)
  static const Color ambientShadowDark = Color(0x3D000000); // Darker shadow for dark mode

  // Fixed Tokens
  static const Color primaryFixed = Color(0xFFE1E0FF);
  static const Color primaryFixedDim = Color(0xFFC0C1FF);
  static const Color onPrimaryFixed = Color(0xFF06006C);
  static const Color onPrimaryFixedVariant = Color(0xFF2E2EBE);

  static const Color secondaryFixed = Color(0xFFC8E6FF);
  static const Color secondaryFixedDim = Color(0xFF89CEFF);
  static const Color onSecondaryFixed = Color(0xFF001E2F);
  static const Color onSecondaryFixedVariant = Color(0xFF004C6E);

  static const Color tertiaryFixed = Color(0xFFFFDADB);
  static const Color tertiaryFixedDim = Color(0xFFFFB2B7);
  static const Color onTertiaryFixed = Color(0xFF40000D);
  static const Color onTertiaryFixedVariant = Color(0xFF920029);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F111E);
  static const Color onBackgroundDark = Color(0xFFE3E1EC);
  static const Color surfaceDark = Color(0xFF0F111E);
  static const Color onSurfaceDark = Color(0xFFE3E1EC);
  static const Color surfaceVariantDark = Color(0xFF434552);
  static const Color onSurfaceVariantDark = Color(0xFFC6C5D7);
  static const Color surfaceDimDark = Color(0xFF0F111E);
  static const Color surfaceBrightDark = Color(0xFF383846);
  static const Color surfaceContainerLowestDark = Color(0xFF0B0D16);
  static const Color surfaceContainerLowDark = Color(0xFF1B1D2A);
  static const Color surfaceContainerDark = Color(0xFF232535);
  static const Color surfaceContainerHighDark = Color(0xFF2D2E40);
  static const Color surfaceContainerHighestDark = Color(0xFF38394C);

  static const Color primaryDark = Color(0xFFC0C1FF);
  static const Color onPrimaryDark = Color(0xFF06006C);
  static const Color primaryContainerDark = Color(0xFF2E2EBE);
  static const Color onPrimaryContainerDark = Color(0xFFE1E0FF);

  static const Color secondaryDark = Color(0xFF89CEFF);
  static const Color onSecondaryDark = Color(0xFF00344D);
  static const Color secondaryContainerDark = Color(0xFF004C6E);
  static const Color onSecondaryContainerDark = Color(0xFFC8E6FF);

  static const Color tertiaryDark = Color(0xFFFFB2B7);
  static const Color onTertiaryDark = Color(0xFF5F0016);
  static const Color tertiaryContainerDark = Color(0xFF920029);
  static const Color onTertiaryContainerDark = Color(0xFFFFDADB);

  static const Color outlineDark = Color(0xFF8F8F9F);
  static const Color outlineVariantDark = Color(0xFF434552);

  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFB4AB);

  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        inversePrimary: inversePrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
      );

  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryDark,
        onPrimary: onPrimaryDark,
        primaryContainer: primaryContainerDark,
        onPrimaryContainer: onPrimaryContainerDark,
        inversePrimary: primary,
        secondary: secondaryDark,
        onSecondary: onSecondaryDark,
        secondaryContainer: secondaryContainerDark,
        onSecondaryContainer: onSecondaryContainerDark,
        tertiary: tertiaryDark,
        onTertiary: onTertiaryDark,
        tertiaryContainer: tertiaryContainerDark,
        onTertiaryContainer: onTertiaryContainerDark,
        error: errorDark,
        onError: onErrorDark,
        errorContainer: errorContainerDark,
        onErrorContainer: onErrorContainerDark,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        surfaceContainerHighest: surfaceContainerHighestDark,
        onSurfaceVariant: onSurfaceVariantDark,
        outline: outlineDark,
        outlineVariant: outlineVariantDark,
        inverseSurface: surface,
        onInverseSurface: onSurface,
      );
}
