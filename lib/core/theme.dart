import 'package:flutter/material.dart';
import 'constants.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFFEC4899);

  // Background Colors
  static const Color backgroundColor = Color(0xFF0F0F0F);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF252525);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF666666);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  // Mood Gradient Colors
  static const List<List<Color>> moodGradients = [
    // Cozy
    [Color(0xFFFF9A56), Color(0xFFFF6B6B), Color(0xFFFFA07A)],
    // Energetic
    [Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFFFF4757)],
    // Melancholic
    [Color(0xFF4A5568), Color(0xFF2D3748), Color(0xFF1A202C)],
    // Calm
    [Color(0xFF81E6D9), Color(0xFF4299E1), Color(0xFF667EEA)],
    // Nostalgic
    [Color(0xFFD4A574), Color(0xFFC19A6B), Color(0xFFB8956A)],
    // Romantic
    [Color(0xFFFF6B9D), Color(0xFFC44569), Color(0xFFFF8FB1)],
  ];

  /// Light Theme (for future use)
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        // fontFamily: 'Inter', // Commented out - using system default fonts
      );

  /// Dark Theme (default)
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        // fontFamily: 'Inter', // Commented out - using system default fonts
        scaffoldBackgroundColor: backgroundColor,

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
        ),

        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingL,
              vertical: AppConstants.spacingM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.buttonBorderRadius,
              ),
            ),
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonBorderRadius,
            ),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonBorderRadius,
            ),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonBorderRadius,
            ),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),

        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: textTertiary,
          ),
        ),
      );

  /// Get mood gradient colors by index
  static List<Color> getMoodGradient(int index) {
    if (index < 0 || index >= moodGradients.length) {
      return moodGradients[0];
    }
    return moodGradients[index];
  }

  /// Get mood gradient by mood label
  static List<Color> getMoodGradientByLabel(String label) {
    final index = AppConstants.moodLabels.indexOf(label);
    return getMoodGradient(index);
  }
}
