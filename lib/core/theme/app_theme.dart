import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme – Custom Material 3 Theme for the application
class AppTheme {
  AppTheme._();

  // Primary colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF00A896);

  // Status colors
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Surface colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);

  // Common spacings
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;

  // Common border radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme
  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: primary,
      surface: surface,
      onSurface: Colors.black87,
    );
    return _buildTheme(colorScheme, Brightness.light);
  }

  // Dark Theme
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: primaryLight,
      secondary: secondaryLight,
    );
    return _buildTheme(colorScheme, Brightness.dark);
  }

  // Build the theme with shared configurations
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final baseTextTheme = isLight
        ? GoogleFonts.interTextTheme()
        : GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: baseTextTheme,

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        titleTextStyle: baseTextTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(radiusMedium),
          // ),
          textStyle: baseTextTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: baseTextTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: baseTextTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        hintStyle: baseTextTheme.bodySmall!.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        labelStyle: baseTextTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        selectedLabelStyle: baseTextTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: baseTextTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.normal,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surface,
        contentTextStyle: baseTextTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurface,
        ),
        actionTextColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }
}
