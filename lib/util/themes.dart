import 'package:flutter/material.dart';

/// Helper class for applying consistent styling across the app.
/// Utilizes styles of the given [BuildContext] - which should be one of:
/// [lightTheme], [darkTheme].
class ThemeHelper {
  // TODO: Update the color list to fit our theme (both light and dark).
  /// Colors available as a preset card or widget background.
  static final Map<Color, String> backgroundColors = {
    Colors.red: 'Red',
    Colors.green: 'Green',
    Colors.blue: 'Blue',
    Colors.orange: 'Orange',
    Colors.brown: 'Brown',
    Colors.pink: 'Pink',
    Colors.purple: 'Purple',
  };

  // TODO: Update the icon list so that it makes more sense.
  // TODO: IconData codes: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/material/icons.dart
  /// Codes of available preset card icons.
  static const Map<int, String> presetIconCodes = {
    0xe03d: 'Accessibility', // accessibility_new
    0xee30: 'Account balance', // account_balance
    0xe042: 'Account box', // account_box
    0xe046: 'ADB', // adb
    0xe749: 'Add alert', // add_alert_sharp,
    0xf516: 'AC unit', // ac_unit_rounded,
  };

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

  static Color widgetDialogHighlightColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color widgetDialogInverseColorForeground(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color widgetDialogInverseColorBackground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color widgetDialogNormalColorForeground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Use this for game widget background color.
  /// Can be used as a default value, but widgets should have configurable colors.
  static Color widgetBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  /// Border radius to use across the application.
  static double borderRadius() {
    return 8.0;
  }

  /// Spacing between chips in forms across the application
  static const double widgetDialogChipSpacing = 10;

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

  /// Spacing between items in selection dialogs.
  static double selectDialogItemSpacing() {
    return 8.0;
  }

  /// Decoration for form text input fields.
  static InputDecoration textInputDecoration(
      BuildContext context, String? label) {
    return InputDecoration(
      labelText: label,
      focusColor: Theme.of(context).colorScheme.onSurface,
      hoverColor: Theme.of(context).colorScheme.onSurface,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      )),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurface,
      )),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onError,
      )),
      contentPadding: const EdgeInsets.all(8.0),
    );
  }

  static ElevatedButton buttonPrimary(
      {required BuildContext context,
      void Function()? onPressed,
      required String label}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Text(label),
    );
  }

  static ElevatedButton buttonSecondary(
      {required BuildContext context,
      void Function()? onPressed,
      required String label}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      child: Text(label),
    );
  }

  static ElevatedButton buttonWarn(
      {required BuildContext context,
      void Function()? onPressed,
      required String label}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      child: Text(label),
    );
  }
}

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF5865F2),
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
  surfaceVariant: Color(0xFF8892f6),
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
  unselectedWidgetColor: darkColorScheme.onSurface,
  toggleableActiveColor: darkColorScheme.onSurface,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: darkColorScheme.onPrimary,
    selectionColor: darkColorScheme.onPrimary,
    selectionHandleColor: darkColorScheme.onPrimary,
  ),
  iconTheme: const IconThemeData(
    size: 24,
  ),
);

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF5865F2),
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
  surfaceVariant: Color(0xFF5865F2),
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
  unselectedWidgetColor: lightColorScheme.onSurface,
  toggleableActiveColor: lightColorScheme.onSurface,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: lightColorScheme.onPrimary,
    selectionColor: lightColorScheme.onPrimary,
    selectionHandleColor: lightColorScheme.onPrimary,
  ),
  iconTheme: const IconThemeData(
    size: 24,
  ),
);

ColorScheme debugColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.deepPurple.shade600,
  onPrimary: Colors.deepPurple.shade200,
  secondary: Colors.orange.shade600,
  onSecondary: Colors.orange.shade200,
  tertiary: Colors.green.shade600,
  onTertiary: Colors.green.shade200,
  error: Colors.red.shade600,
  onError: Colors.red.shade200,
  background: Colors.brown.shade600,
  onBackground: Colors.brown.shade200,
  surface: Colors.teal.shade600,
  onSurface: Colors.teal.shade200,
  surfaceVariant: Colors.tealAccent,
);

/// Debug theme; use when building the app (for finding theme inconsistencies).
final ThemeData debugTheme = ThemeData(
  textTheme: Typography.whiteCupertino.apply(
    bodyColor: debugColorScheme.onPrimary,
    displayColor: debugColorScheme.onPrimary,
  ),
  colorScheme: debugColorScheme,
  brightness: debugColorScheme.brightness,
  primaryColor: debugColorScheme.primary,
  backgroundColor: debugColorScheme.background,
  unselectedWidgetColor: debugColorScheme.onSurface,
  toggleableActiveColor: debugColorScheme.onSurface,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: debugColorScheme.onPrimary,
    selectionColor: debugColorScheme.onPrimary,
    selectionHandleColor: debugColorScheme.onPrimary,
  ),
  iconTheme: const IconThemeData(
    size: 24,
  ),
);
