import 'package:flutter/material.dart';

class Constants {
  // Theme Colors (maintained for backward compatibility)
  final Color primaryColor = const Color(0xff90B2F9);
  final Color secondaryColor = const Color(0xff90B2F8);

  // Extended Color Palette
  static const Color accentBlue = Color(0xFF4A8BF5);
  static const Color gradientStart = Color(0xFF2E3192);
  static const Color gradientMiddle = Color(0xFF1BCEDF);
  static const Color gradientDeep = Color(0xFF1E3C72);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Weather Colors
  static const Color sunny = Color(0xFFFFB300);
  static const Color cloudy = Color(0xFF90A4AE);
  static const Color rainy = Color(0xFF42A5F5);

  // API Configuration
  static const String apiKey = "094b10e5eb8502d33a9a80dcb91877d6";

  // App Configuration
  static const String appName = "HordricWeather";
  static const double defaultBorderRadius = 20.0;
  static const double defaultElevation = 4.0;
}
