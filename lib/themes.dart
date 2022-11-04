import 'package:flutter/material.dart';

/// Helper class for applying consistent styling across the app.
/// Utilizes styles of the given [BuildContext] - which should be one of:
/// [lightTheme], [darkTheme].
class ThemeHelper {

  /// Use this for game widget main titles.
  static TextStyle widgetTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: Colors.white,
    );
  }

  /// Use this for game widget bottom titles.
  static TextStyle widgetTitleBottom(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      color: Colors.white,
    );
  }

  /// Use this for the main content of the game widget titles.
  /// Size should be adjusted based on the available space.
  static TextStyle widgetContentMain(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!;
  }

  /// Use this for the secondary content of the game widget titles.
  /// Size should be adjusted based on the available space.
  static TextStyle widgetContentSecondary(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!;
  }

  /// Use this for game widget background color.
  static Color widgetBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Border radius to use across the application.
  static int borderRadius() {
    return 12;
  }

  /// Spacing between cards across the application.
  static int cardSpacing() {
    return 20;
  }
}

/// Dark theme; use when building the app.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: Typography.whiteCupertino,
  colorScheme: ColorScheme.dark(
    surface: Colors.blue[700]!,
    error: Colors.red[700]!,
    primary: Colors.grey[600]!,
    secondary: Colors.grey[700]!,
    tertiary: Colors.grey[800]!,
    background: Colors.black26,
  ),
  primaryColor: Colors.grey[700]!,
  backgroundColor: Colors.black26,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
);

/// Light theme; use when building the app.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: Typography.blackCupertino,
  colorScheme: ColorScheme.light(
    surface: Colors.blue[300]!,
    error: Colors.red[300]!,
    primary: Colors.grey[500]!,
    secondary: Colors.grey[400]!,
    tertiary: Colors.grey[300]!,
    background: Colors.white,
  ),
  primaryColor: Colors.grey[400]!,
  backgroundColor: Colors.white,
  iconTheme: const IconThemeData(
    color: Colors.black,
  ),
);