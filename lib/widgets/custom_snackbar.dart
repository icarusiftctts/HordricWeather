import 'package:flutter/material.dart';

/// Helper to show a custom floating SnackBar.
/// Example: showCustomSnackBar(context, 'Your message');
void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final theme = Theme.of(context);
  final bgColor = isError ? theme.colorScheme.error : theme.colorScheme.primary;

  final snack = SnackBar(
    content: Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary),
    ),
    behavior: SnackBarBehavior.floating, // floating above bottom
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // adds margin
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    backgroundColor: bgColor,
    elevation: 6,
    duration: duration,
  );

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar(); // hides old one if showing
  messenger.showSnackBar(snack);
}
