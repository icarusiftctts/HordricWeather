import 'package:flutter/material.dart';

class ChartTheme {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.grey[900]!.withOpacity(0.1)
        : Colors.white.withOpacity(0.1);
  }

  static Color getBorderColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.2);
  }

  static Color getTextColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.white.withOpacity(0.9)
        : Colors.white;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.white.withOpacity(0.7)
        : Colors.white.withOpacity(0.8);
  }

  static Color getGridColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.1);
  }

  static List<Color> getTemperatureGradient(BuildContext context) {
    return isDarkMode(context)
        ? [Colors.orange.shade300, Colors.red.shade300]
        : [Colors.orange.shade400, Colors.red.shade400];
  }

  static List<Color> getPrecipitationGradient(BuildContext context) {
    return isDarkMode(context)
        ? [Colors.blue.shade300, Colors.cyan.shade300]
        : [Colors.blue.shade400, Colors.cyan.shade400];
  }

  static List<Color> getHumidityGradient(BuildContext context) {
    return isDarkMode(context)
        ? [Colors.teal.shade300, Colors.green.shade300]
        : [Colors.teal.shade400, Colors.green.shade400];
  }

  static List<BoxShadow> getCardShadows(BuildContext context) {
    return isDarkMode(context)
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ]
        : [
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
          ];
  }
}
