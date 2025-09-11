import 'package:flutter/material.dart';

class ThemeHelpers {
  // Get appropriate border for dark/light theme
  static BorderSide getThemeBorder(BuildContext context, {double width = 1.0, double opacity = 0.2}) {
    return BorderSide(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(opacity)
          : Colors.transparent,
      width: width,
    );
  }

  // Get appropriate card shape with border
  static RoundedRectangleBorder getCardShape(BuildContext context, {double radius = 12.0, double borderWidth = 1.0}) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: getThemeBorder(context, width: borderWidth),
    );
  }

  // Get container decoration with theme-appropriate border
  static BoxDecoration getContainerDecoration(
    BuildContext context, {
    Color? backgroundColor,
    double radius = 12.0,
    double borderWidth = 1.0,
    double borderOpacity = 0.2,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(borderOpacity)
            : Colors.transparent,
        width: borderWidth,
      ),
      boxShadow: boxShadow,
    );
  }

  // Get button decoration with theme-appropriate styling
  static BoxDecoration getButtonDecoration(
    BuildContext context, {
    required Color baseColor,
    double radius = 6.0,
    double borderWidth = 1.0,
    double backgroundOpacity = 0.1,
    double borderOpacity = 0.3,
  }) {
    return BoxDecoration(
      color: baseColor.withOpacity(backgroundOpacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(borderOpacity)
            : Colors.transparent,
        width: borderWidth,
      ),
    );
  }

  // Get text color based on theme
  static Color? getTextColor(BuildContext context, {double opacity = 1.0}) {
    return Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(opacity);
  }

  // Get secondary text color based on theme
  static Color? getSecondaryTextColor(BuildContext context, {double opacity = 0.7}) {
    return Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(opacity);
  }

  // Get heading text color - white for dark theme, black for light theme
  static Color getHeadingColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  // Get primary text color - light grey for dark theme, dark grey for light theme
  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.grey[800]!;
  }

  // Get secondary text color - lighter grey for dark theme, medium grey for light theme
  static Color getSecondaryGreyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;
  }

  // Get subtle text color - more muted for less important text
  static Color getSubtleTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[500]!
        : Colors.grey[500]!;
  }
}
