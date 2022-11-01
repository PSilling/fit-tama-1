import 'package:flutter/material.dart';

/// Helper class for applying consistent styling across the app.
/// Utilizes styles of the given [BuildContext] - which should be on of:
/// [lightTheme], [darkTheme].
class ThemeHelper {

  /// Use this for game widget titles.
  static TextStyle widgetTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!;
  }
}

/// Light theme; use when building the app.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
);

/// Dark theme; use when building the app.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
);