import 'package:flutter/material.dart';

class CommonSnackbar {
  /// Show a material snackbar
  static void show(
    BuildContext context, {
    required String message,
    bool error = false,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        backgroundColor ?? (isDark ? Colors.grey[900] : Colors.grey[200]);
    final fgColor = textColor ?? (isDark ? Colors.white : Colors.black87);

    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: fgColor),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: fgColor, fontWeight: FontWeight.w500),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                onAction();
              },
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
