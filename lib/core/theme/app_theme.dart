import 'package:flutter/material.dart';

/// HordricWeather Application Theme
///
/// This file contains the centralized theme configuration for the application.
/// All colors, text styles, and component themes are defined here to ensure
/// visual consistency across all screens.

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============================================================================
  // COLOR PALETTE
  // ============================================================================

  // Primary Colors
  static const Color primaryBlue = Color(0xFF90B2F9);
  static const Color secondaryBlue = Color(0xFF6A9EF7);
  static const Color accentBlue = Color(0xFF4A8BF5);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF2E3192);
  static const Color gradientMiddle = Color(0xFF1BCEDF);
  static const Color gradientDeep = Color(0xFF1E3C72);
  static const Color gradientLight = Color(0xFF4A90E2);

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundLightBlue =
      Color(0xFFF0F4FF); // Light blue background
  static const Color backgroundLavender =
      Color(0xFFF8F9FF); // Very light lavender background
  static const Color cardBackground = Colors.white;
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Weather Condition Colors
  static const Color sunny = Color(0xFFFFB300);
  static const Color cloudy = Color(0xFF90A4AE);
  static const Color rainy = Color(0xFF42A5F5);
  static const Color stormy = Color(0xFF5C6BC0);
  static const Color snowy = Color(0xFFE1F5FE);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnPrimaryLight =
      Color(0xFFE8F0FE); // Light blue-white for icons
  static const Color textHint = Color(0xFFBDBDBD);

  // Overlay Colors
  static Color overlay10 = Colors.white.withOpacity(0.1);
  static Color overlay15 = Colors.white.withOpacity(0.15);
  static Color overlay20 = Colors.white.withOpacity(0.2);
  static Color overlay25 = Colors.white.withOpacity(0.25);
  static Color overlay30 = Colors.white.withOpacity(0.3);

  static Color darkOverlay10 = Colors.black.withOpacity(0.1);
  static Color darkOverlay15 = Colors.black.withOpacity(0.15);
  static Color darkOverlay20 = Colors.black.withOpacity(0.2);

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, secondaryBlue, accentBlue],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientMiddle],
    stops: [0.0, 1.0],
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      gradientDeep,
      Color(0xFF2A5298),
      gradientDeep,
      gradientLight,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static LinearGradient homeGradient(Color backgroundColor) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryBlue,
          primaryBlue.withOpacity(0.8),
          secondaryBlue.withOpacity(0.6),
          backgroundColor,
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );

  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.25),
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.05),
    ],
  );

  static LinearGradient glassCardGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.2),
      Colors.white.withOpacity(0.1),
    ],
  );

  // ============================================================================
  // TEXT THEMES
  // ============================================================================

  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textOnPrimary,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textOnPrimary,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textOnPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: textOnPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textOnPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textOnPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textOnPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textOnPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textOnPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: textOnPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: textOnPrimary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: textOnPrimary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textOnPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textOnPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textOnPrimary,
    ),
  );

  // ============================================================================
  // COMPONENT THEMES
  // ============================================================================

  static final BoxDecoration glassCardDecoration = BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(30),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 30,
        offset: const Offset(0, 15),
        spreadRadius: -5,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, -5),
        spreadRadius: -2,
      ),
    ],
  );

  static BoxDecoration containerDecoration({
    double borderRadius = 20,
    Color? backgroundColor,
    bool withBorder = true,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      gradient: backgroundColor == null ? glassCardGradient : null,
      borderRadius: BorderRadius.circular(borderRadius),
      border: withBorder
          ? Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            )
          : null,
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
    );
  }

  // ============================================================================
  // BUTTON STYLES
  // ============================================================================

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: cardBackground,
    foregroundColor: gradientDeep,
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  static final ButtonStyle glassButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.2),
    foregroundColor: textOnPrimary,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(color: Colors.white.withOpacity(0.3)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  );

  // ============================================================================
  // INPUT DECORATION
  // ============================================================================

  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: error, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
  );

  // ============================================================================
  // MATERIAL THEME
  // ============================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryBlue,
        tertiary: accentBlue,
        surface: cardBackground,
        background: backgroundLight,
        error: error,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: textOnPrimary,
        brightness: Brightness.light,
      ),

      // Text Theme
      textTheme: lightTextTheme,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textOnPrimary, size: 24),
        titleTextStyle: TextStyle(
          color: textOnPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: inputDecorationTheme,

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textOnPrimary,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: overlay15,
        labelStyle: const TextStyle(color: textOnPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: overlay30),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: textOnPrimary,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return cardBackground;
          }
          return Colors.white.withOpacity(0.5);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return overlay30;
          }
          return overlay10;
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: textOnPrimary,
        unselectedLabelColor: Colors.white70,
        indicator: BoxDecoration(
          color: overlay30,
          borderRadius: BorderRadius.circular(25),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
        elevation: 8,
      ),
    );
  }

  // ============================================================================
  // SPACING & SIZING CONSTANTS
  // ============================================================================

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacing3XL = 30.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 15.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 25.0;
  static const double radius3XL = 30.0;

  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 48.0;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  static const Duration animationFast = Duration(milliseconds: 300);
  static const Duration animationMedium = Duration(milliseconds: 600);
  static const Duration animationSlow = Duration(milliseconds: 1000);
}
