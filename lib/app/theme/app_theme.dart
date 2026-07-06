import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Taleem Design System theme configuration.
///
/// Implements the Taleem Glass design language with M3 color semantics,
/// Hanken Grotesk / Inter typography, ambient shadows, and glassmorphism
/// tokens exposed via extension colors.
class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════════
  // ── Colour Palette ──────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════

  // Primary
  static const Color _primary = Color(0xFF2C2ABC);
  static const Color _primaryContainer = Color(0xFF4648D4);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onPrimaryContainer = Color(0xFFD1D1FF);
  static const Color _primaryFixed = Color(0xFFE1E0FF);

  // Secondary
  static const Color _secondary = Color(0xFF006590);
  static const Color _secondaryContainer = Color(0xFF85CBFD);
  static const Color _onSecondary = Color(0xFFFFFFFF);
  static const Color _onSecondaryContainer = Color(0xFF00567C);

  // Tertiary
  static const Color _tertiary = Color(0xFF8E0028);
  static const Color _tertiaryContainer = Color(0xFFB90538);
  static const Color _onTertiary = Color(0xFFFFFFFF);
  static const Color _onTertiaryContainer = Color(0xFFFFC7CA);

  // Surfaces
  static const Color _surface = Color(0xFFFAF8FF);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color _surfaceContainer = Color(0xFFEAEDFF);
  static const Color _surfaceContainerHigh = Color(0xFFE1E7FF);
  static const Color _surfaceContainerHighest = Color(0xFFDAE2FC);
  static const Color _surfaceDim = Color(0xFFD2D9F4);
  static const Color _surfaceBright = Color(0xFFFAF8FF);

  // On Surface
  static const Color _onSurface = Color(0xFF131B2E);
  static const Color _onSurfaceVariant = Color(0xFF464554);

  // Outline
  static const Color _outline = Color(0xFF767586);
  static const Color _outlineVariant = Color(0xFFC6C5D7);

  // Error
  static const Color _error = Color(0xFFBA1A1A);
  static const Color _onError = Color(0xFFFFFFFF);
  static const Color _errorContainer = Color(0xFFFFDAD6);
  static const Color _onErrorContainer = Color(0xFF93000A);

  // Inverse
  static const Color _inverseSurface = Color(0xFF283044);
  static const Color _inverseOnSurface = Color(0xFFEEF0FF);
  static const Color _inversePrimary = Color(0xFFC0C1FF);

  // Extended
  static const Color _successContainer = Color(0xFFC9E6FF);
  static const Color _warningContainer = Color(0xFFFFDAD6);

  // ══════════════════════════════════════════════════════════════
  // ── Light Theme ─────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light().copyWith(
      primary: _primary,
      primaryContainer: _primaryContainer,
      onPrimary: _onPrimary,
      onPrimaryContainer: _onPrimaryContainer,
      primaryFixed: _primaryFixed,
      secondary: _secondary,
      secondaryContainer: _secondaryContainer,
      onSecondary: _onSecondary,
      onSecondaryContainer: _onSecondaryContainer,
      tertiary: _tertiary,
      tertiaryContainer: _tertiaryContainer,
      onTertiary: _onTertiary,
      onTertiaryContainer: _onTertiaryContainer,
      surface: _surface,
      surfaceContainerLowest: _surfaceContainerLowest,
      surfaceContainerLow: _surfaceContainerLow,
      surfaceContainer: _surfaceContainer,
      surfaceContainerHigh: _surfaceContainerHigh,
      surfaceContainerHighest: _surfaceContainerHighest,
      surfaceDim: _surfaceDim,
      surfaceBright: _surfaceBright,
      onSurface: _onSurface,
      onSurfaceVariant: _onSurfaceVariant,
      outline: _outline,
      outlineVariant: _outlineVariant,
      error: _error,
      onError: _onError,
      errorContainer: _errorContainer,
      onErrorContainer: _onErrorContainer,
      inverseSurface: _inverseSurface,
      inversePrimary: _inversePrimary,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ══════════════════════════════════════════════════════════════
  // ── Dark Theme ──────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark().copyWith(
      primary: _inversePrimary,
      primaryContainer: _primary,
      onPrimary: Color(0xFF06006C),
      onPrimaryContainer: _onPrimaryContainer,
      primaryFixed: _primaryFixed,
      secondary: Color(0xFF89CEFF),
      secondaryContainer: Color(0xFF004C6E),
      onSecondary: Color(0xFF003451),
      onSecondaryContainer: Color(0xFFC8E6FF),
      tertiary: Color(0xFFFFB2B7),
      tertiaryContainer: Color(0xFF920029),
      onTertiary: Color(0xFF670017),
      onTertiaryContainer: Color(0xFFFFDADB),
      surface: Color(0xFF111827),
      surfaceContainerLowest: Color(0xFF0A0F1A),
      surfaceContainerLow: Color(0xFF171D2F),
      surfaceContainer: Color(0xFF1C2338),
      surfaceContainerHigh: Color(0xFF262D42),
      surfaceContainerHighest: Color(0xFF31384D),
      surfaceDim: Color(0xFF111827),
      surfaceBright: Color(0xFF363E54),
      onSurface: Color(0xFFE2E2F0),
      onSurfaceVariant: Color(0xFFC6C5D7),
      outline: Color(0xFF908FA0),
      outlineVariant: Color(0xFF464554),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: _errorContainer,
      inverseSurface: Color(0xFFE2E2F0),
      inversePrimary: _primary,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ══════════════════════════════════════════════════════════════
  // ── Shared Builder ──────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════

  static ThemeData _buildTheme(ColorScheme cs, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.hankenGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
        color: cs.onSurface,
      ),
      displayMedium: GoogleFonts.hankenGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        letterSpacing: -0.02 * 36,
        color: cs.onSurface,
      ),
      displaySmall: GoogleFonts.hankenGrotesk(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 38 / 30,
        color: cs.onSurface,
      ),
      headlineLarge: GoogleFonts.hankenGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
        color: cs.onSurface,
      ),
      headlineMedium: GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: cs.onSurface,
      ),
      headlineSmall: GoogleFonts.hankenGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: cs.onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: cs.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        color: cs.onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: cs.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: cs.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: cs.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: cs.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: cs.onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: cs.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 16 / 11,
        letterSpacing: 0.05 * 11,
        color: cs.onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isLight
            ? const Color(0xB3FFFFFF) // white 70%
            : cs.surfaceContainer,
        foregroundColor: cs.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLight ? Colors.white.withValues(alpha: 0.8) : cs.outlineVariant,
          ),
        ),
        color: isLight
            ? const Color(0xB3FFFFFF) // white 70%
            : cs.surfaceContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: cs.outline),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: cs.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: const CircleBorder(),
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isLight
            ? const Color(0xB3FFFFFF)
            : cs.surfaceContainer,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.primaryFixed,
        labelStyle: textTheme.labelSmall?.copyWith(color: cs.primary),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: isLight ? _inverseOnSurface : cs.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ── Design Token Helpers ────────────────────────────────────
  // ══════════════════════════════════════════════════════════════

  /// Ambient indigo-tinted shadow for elevated glass elements.
  static List<BoxShadow> get ambientShadow => [
        const BoxShadow(
          color: Color(0x264648D4), // rgba(70,72,212,0.15)
          blurRadius: 30,
          offset: Offset(0, 10),
          spreadRadius: -10,
        ),
      ];

  /// Standard glass panel decoration.
  static BoxDecoration glassDecoration({
    double borderRadius = 12,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: const Color(0xB3FFFFFF), // white 70%
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.8),
      ),
      boxShadow: showShadow
          ? [
              const BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: -1,
              ),
              const BoxShadow(
                color: Color(0x08000000),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: -1,
              ),
            ]
          : null,
    );
  }

  /// Extended palette colors not in M3 ColorScheme.
  static const Color successContainer = _successContainer;
  static const Color warningContainer = _warningContainer;
  static const Color surfaceGlass = Color(0xB3FFFFFF);
}
