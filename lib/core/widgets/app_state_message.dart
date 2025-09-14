import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppStateMessage extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const AppStateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.iconColor,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child:
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 64,
                      color: iconColor ?? theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (primaryLabel != null || secondaryLabel != null) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (primaryLabel != null)
                            ElevatedButton(
                              onPressed: onPrimary,
                              child: Text(primaryLabel!),
                            ),
                          if (secondaryLabel != null)
                            OutlinedButton(
                              onPressed: onSecondary,
                              child: Text(secondaryLabel!),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.9, 0.9), duration: 400.ms),
    );
  }
}
