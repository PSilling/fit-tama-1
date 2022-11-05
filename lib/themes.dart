import 'package:flutter/material.dart';

/// Helper class for applying consistent styling across the app.
/// Utilizes styles of the given [BuildContext] - which should be one of:
/// [lightTheme], [darkTheme].
class ThemeHelper {

  /// Use this for game widget main titles.
  static TextStyle widgetTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Use this for game widget bottom titles.
  static TextStyle widgetTitleBottom(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Use this for the main content of the game widget titles.
  /// Size should be adjusted based on the available space.
  static TextStyle widgetContentMain(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Use this for the secondary content of the game widget titles.
  /// Size should be adjusted based on the available space.
  static TextStyle widgetContentSecondary(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }

  /// Use this for game widget background color.
  /// Just a placeholder, widgets will have configurable colors, TODO: remove.
  static Color widgetBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Border radius to use across the application.
  static double borderRadius() {
    return 8.0;
  }

  /// Spacing between cards across the application.
  static double cardSpacing() {
    return 8.0;
  }

  /// Lower than [FloatingActionButton]'s default (6).
  static double cardElevation() {
    return 4.0;
  }

  /// Padding around card content.
  static EdgeInsets cardPadding() {
    return const EdgeInsets.all(8.0);
  }

  /// Decoration for form text input fields.
  static InputDecoration textInputDecoration(BuildContext context, String? label) {
    return InputDecoration(
      labelText: label,
      focusColor: Theme.of(context).colorScheme.onPrimary,
      hoverColor: Theme.of(context).colorScheme.onPrimary,
      contentPadding: const EdgeInsets.all(8.0),
    );
  }

  static ElevatedButton buttonPrimary({required BuildContext context, void Function()? onPressed, required String label}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: Text(label),
    );
  }

  static ElevatedButton buttonSecondary({required BuildContext context, void Function()? onPressed, required String label}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      child: Text(label),
    );
  }

  static ElevatedButton buttonWarn({required BuildContext context, void Function()? onPressed, required String label}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
      child: Text(label),
    );
  }
}

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFF4752C4),
  onPrimary: Colors.white,
  secondary: Color(0xFF2F3136),
  onSecondary: Colors.white,
  tertiary: Color(0xFF202225),
  onTertiary: Colors.white,

  error: Color(0xFFD83C3E),
  onError: Colors.white,

  background: Color(0xFF36393F),
  onBackground: Colors.white,

  surface: Color(0xFF40444B),
  onSurface: Colors.white,
);

/// Dark theme; use when building the app.
final ThemeData darkTheme = ThemeData(

  textTheme: Typography.whiteCupertino.apply(
    bodyColor: darkColorScheme.onPrimary,
    displayColor: darkColorScheme.onPrimary,
  ),

  colorScheme: darkColorScheme,
  brightness: darkColorScheme.brightness,
  primaryColor: darkColorScheme.primary,
  backgroundColor: darkColorScheme.background,

  textSelectionTheme: TextSelectionThemeData(
    cursorColor: darkColorScheme.onPrimary,
    selectionColor: darkColorScheme.onPrimary,
    selectionHandleColor: darkColorScheme.onPrimary,
  ),

  iconTheme: IconThemeData(
    color: darkColorScheme.onBackground,
    size: 24,
  ),
);

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFF4752C4),
  onPrimary: Colors.white,
  secondary: Color(0xFF2F3136),
  onSecondary: Colors.white,
  tertiary: Color(0xFFE3E5E8),
  onTertiary: Colors.black,

  error: Color(0xFFD83C3E),
  onError: Colors.white,

  background: Colors.white,
  onBackground: Colors.black,

  surface: Color(0xFFEBEDEF),
  onSurface: Colors.black,
);

/// Light theme; use when building the app.
final ThemeData lightTheme = ThemeData(

  textTheme: Typography.whiteCupertino.apply(
    bodyColor: lightColorScheme.onPrimary,
    displayColor: lightColorScheme.onPrimary,
  ),

  colorScheme: lightColorScheme,
  brightness: lightColorScheme.brightness,
  primaryColor: lightColorScheme.primary,
  backgroundColor: lightColorScheme.background,

  textSelectionTheme: TextSelectionThemeData(
    cursorColor: lightColorScheme.onPrimary,
    selectionColor: lightColorScheme.onPrimary,
    selectionHandleColor: lightColorScheme.onPrimary,
  ),

  iconTheme: IconThemeData(
    color: lightColorScheme.onBackground,
    size: 24,
  ),
);