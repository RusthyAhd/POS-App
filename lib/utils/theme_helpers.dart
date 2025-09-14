import 'package:flutter/material.dart';

class ThemeHelpers {
  // Get appropr  // Get primary text color - white for dark theme, dark grey for light theme  
  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.grey[800]!;
  }

  // Get secondary grey color for less important content dark/light theme
  static BorderSide getThemeBorder(BuildContext context, {double width = 1.0, double opacity = 0.2}) {
    return BorderSide(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: opacity)
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
            ? Colors.white.withValues(alpha: borderOpacity)
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
      color: baseColor.withValues(alpha: backgroundOpacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: borderOpacity)
            : Colors.transparent,
        width: borderWidth,
      ),
    );
  }

  // Get text color based on theme
  static Color? getTextColor(BuildContext context, {double opacity = 1.0}) {
    return Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: opacity);
  }

  // Get secondary text color based on theme
  static Color? getSecondaryTextColor(BuildContext context, {double opacity = 0.7}) {
    return Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: opacity);
  }

  // Get heading text color - white for dark theme, black for light theme
  static Color getHeadingColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  // Get secondary grey color for less important content
  static Color getSecondaryGreyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;
  }

  // Get subtle text color - more muted for less important text
  static Color getSubtleTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[500]!;
  }

  // Get bright text color for high visibility in dark theme
  static Color getBrightTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  // Get content text color for body text
  static Color getContentTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[200]!
        : Colors.grey[700]!;
  }

  // Get dialog text color for dialog content
  static Color getDialogTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }
}
