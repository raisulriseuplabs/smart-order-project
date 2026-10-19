import 'package:flutter/material.dart';

class AppTheme {
  // Legacy mapping to new ColorScheme tokens
  static Color primary(BuildContext context) => Theme.of(context).colorScheme.primary;
  static Color onPrimary(BuildContext context) => Theme.of(context).colorScheme.onPrimary;
  static Color secondary(BuildContext context) => Theme.of(context).colorScheme.secondary;
  static Color surface(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color background(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color error(BuildContext context) => Theme.of(context).colorScheme.error;
  static Color outline(BuildContext context) => Theme.of(context).colorScheme.outline;

  // Text Styles
  static TextStyle? headingStyle(BuildContext context) => Theme.of(context).textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle? bodyStyle(BuildContext context) => Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  // Decorations
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration selectedDecoration(BuildContext context) => BoxDecoration(
    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
  );
}
