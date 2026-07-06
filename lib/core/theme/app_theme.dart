import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.background,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.surfaceGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderXl,
          side: const BorderSide(color: Color(0xCCFFFFFF), width: 1.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRegular,
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRegular,
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: const BorderSide(color: AppColors.error, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        selectedIconTheme: IconThemeData(fill: 1.0),
        unselectedIconTheme: IconThemeData(fill: 0.0),
        type: BottomNavigationBarType.fixed,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderFull,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        disabledColor: Colors.transparent,
        selectedColor: AppColors.primaryContainer.withValues(alpha: 0.2),
        secondarySelectedColor: AppColors.secondaryContainer.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        labelStyle: AppTypography.labelCaps.copyWith(color: AppColors.onSurface),
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderXl,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        actionTextColor: AppColors.inverseOnSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.inverseOnSurface),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRegular,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      tabBarTheme: TabBarTheme(
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTypography.bodyMedium,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      textTheme: AppTypography.darkTextTheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.surfaceGlassDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderXl,
          side: const BorderSide(color: Color(0x1BFFFFFF), width: 1.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onPrimaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRegular,
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.outlineVariantDark),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRegular,
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowDark,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: const BorderSide(color: AppColors.errorDark, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRegular,
          borderSide: const BorderSide(color: AppColors.errorDark, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariantDark.withValues(alpha: 0.5)),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariantDark),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.onSurfaceVariantDark,
        selectedIconTheme: IconThemeData(fill: 1.0),
        unselectedIconTheme: IconThemeData(fill: 0.0),
        type: BottomNavigationBarType.fixed,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderFull,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLowDark,
        disabledColor: Colors.transparent,
        selectedColor: AppColors.primaryContainerDark.withValues(alpha: 0.2),
        secondarySelectedColor: AppColors.secondaryContainerDark.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        labelStyle: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceDark),
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.outlineVariantDark.withValues(alpha: 0.3)),
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceContainerLowestDark,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderXl,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighestDark,
        actionTextColor: AppColors.primaryDark,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceDark),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRegular,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      tabBarTheme: TabBarTheme(
        indicatorColor: AppColors.primaryDark,
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: AppColors.onSurfaceVariantDark,
        labelStyle: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTypography.bodyMedium,
      ),
    );
  }
}
class ElevatedButtonButtonThemeData extends ElevatedButtonThemeData {
  const ElevatedButtonButtonThemeData({required super.style});
}
