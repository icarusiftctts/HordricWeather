import 'package:flutter/material.dart';

/// Custom floating SnackBar for HordricWeather
void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final theme = Theme.of(context);
  final bgColor =
      isError ? theme.colorScheme.error : theme.colorScheme.primaryContainer;
  final textColor = theme.colorScheme.onPrimaryContainer;

  final snack = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
    ),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    elevation: 8,
    backgroundColor: bgColor.withOpacity(0.95),
    duration: duration,
  );

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(snack);
}
