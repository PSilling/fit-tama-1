import 'package:flutter/material.dart';

/// Helper class for applying consistent styling across the application.
/// Utilizes styles of the given [BuildContext] - which should be one of:
/// [lightTheme], [darkTheme].
class ThemeHelper {

  static Color floaterBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color floaterForegroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
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

  /// Use this for game widget background color.
  /// Can be used as a default value, but widgets should have configurable colors.
  static Color cardBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  /// Use this for game widget background color.
  /// Can be used as a default value, but widgets should have configurable colors.
  static Color cardForegroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.onTertiary;
  }

  // TODO: Update the color list to fit our theme (both light and dark).
  /// Colors available as a preset card or widget background.
  /// Text with [cardForegroundColor] should be visible on these.
  static final Map<Color, String> cardBackgroundColors = {
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
    0xe038: 'access_alarm',
    0xe03d: 'accessibility_new',
    0xe040: 'account_balance',
    0xe044: 'account_tree',
    0xe04e: 'add_chart',
    0xe063: 'agriculture',
    0xe064: 'air',
    0xe06b: 'airline_seat_recline_extra',
    0xf04bb: 'airline_stops',
    0xe071: 'airport_shuttle',
    0xe07e: 'all_inclusive',
    0xe084: 'anchor',
    0xe087: 'announcement',
    0xe089: 'apartment',
    0xe08c: 'app_registration',
    0xe0ae: 'assistant_photo',
    0xe0b2: 'attach_money',
    0xe0b6: 'audiotrack',
    0xeea9: 'auto_awesome_outlined',
    0xe0bb: 'auto_fix_high',
    0xe0bf: 'auto_stories',
    0xf04c5: 'back_hand',
    0xe0c9: 'bakery_dining',
    0xf04c6: 'balance',
    0xe0d6: 'beach_access',
    0xe0db: 'bedtime',
    0xe0ee: 'bolt',
    0xe0ef: 'book',
    0xe109: 'brightness_5',
    0xe113: 'brush',
    0xe115: 'bug_report',
    0xe116: 'build',
    0xe11c: 'business_center',
  };

  /// Use this for game widget main titles.
  static TextStyle widgetTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: cardForegroundColor(context),
    );
  }

  /// Use this for game widget bottom titles.
  static TextStyle widgetTitleBottom(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      color: cardForegroundColor(context),
    );
  }

  /// Use this for the main content of the game widget titles.
  /// Size should be adjusted based on the available space.
  static TextStyle widgetContentMain(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      color: cardForegroundColor(context),
    );
  }

  /// Use this for the secondary content of the game widget titles.
  /// Size should be adjusted based on the available space.
  static TextStyle widgetContentSecondary(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      color: cardForegroundColor(context).withOpacity(0.7),
    );
  }

  /// Used for highlighting text in dialogs that should stand out.
  static Color dialogForegroundHighlight(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Used for text in dialogs across the application.
  static Color dialogForeground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Used as a background color for dialogs across the application.
  static Color dialogBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Decoration for form fields in dialogs.
  static InputDecoration dialogInputDecoration(BuildContext context,
      {String? label,
        bool? isDense, String? errorText,
        bool hasBorder = true,
        bool hasPadding = true}) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      isDense: isDense,
      prefixStyle: TextStyle(
        color: dialogForeground(context),
      ),
      focusColor: dialogForeground(context),
      hoverColor: dialogForeground(context),
      labelStyle: TextStyle(
        color: dialogForeground(context),
      ),
      errorBorder: hasBorder ? null : InputBorder.none,
      disabledBorder: hasBorder ? null : InputBorder.none,
      enabledBorder: hasBorder ? UnderlineInputBorder(
          borderSide: BorderSide(
            color: dialogForeground(context).withOpacity(0.5),
          )) : InputBorder.none,
      focusedBorder: hasBorder ? UnderlineInputBorder(
          borderSide: BorderSide(
            color: dialogForeground(context),
          )) : InputBorder.none,
      focusedErrorBorder: hasBorder ? UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onError,
          )) : InputBorder.none,
      contentPadding: hasPadding ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
    );
  }

  /// Used for text in edit views across the application.
  static Color editViewForeground(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }

  /// Used as a background color for edit views across the application.
  static Color editViewBackground(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  /// Decoration for form fields in edit views.
  static InputDecoration editViewInputDecoration(BuildContext context,
      {String? label,
        bool? isDense, String? errorText,
        bool hasBorder = true,
        bool hasPadding = true}) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      isDense: isDense,
      prefixStyle: TextStyle(
        color: editViewForeground(context),
      ),
      focusColor: editViewForeground(context),
      hoverColor: editViewForeground(context),
      labelStyle: TextStyle(
        color: editViewForeground(context),
      ),
      errorBorder: hasBorder ? null : InputBorder.none,
      disabledBorder: hasBorder ? null : InputBorder.none,
      enabledBorder: hasBorder ? UnderlineInputBorder(
          borderSide: BorderSide(
            color: editViewForeground(context).withOpacity(0.5),
          )) : InputBorder.none,
      focusedBorder: hasBorder ? UnderlineInputBorder(
          borderSide: BorderSide(
            color: editViewForeground(context),
          )) : InputBorder.none,
      focusedErrorBorder: hasBorder ? UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onError,
          )) : InputBorder.none,
      contentPadding: hasPadding ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
    );
  }

  /// Spacing between chips in forms across the application
  static const double dialogChipSpacing = 10;

  /// Used as a background color for pop-up menus across the application.
  static Color popUpBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  // Used as a text style for pop-up menu items across the application.
  static TextStyle popUpTextStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSecondary,
    );
  }

  /// Use this for textfields in edit dialog
  static TextStyle textFieldStyle(BuildContext context) {
    return TextStyle(color: Theme.of(context).colorScheme.onSurface);
  }

  /// Use this for the textfields in edit dialog for cursorColor
  static Color textFieldCursorColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Border radius to use across the application.
  static double borderRadius() {
    return 8.0;
  }

  /// Spacing between items in selection dialogs.
  static double selectDialogItemSpacing() {
    return 8.0;
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
  surfaceVariant: Color(0xFF40444B),
  onSurfaceVariant: Color(0xFFF092DD),
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
    selectionColor: darkColorScheme.onPrimary.withOpacity(0.5),
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
  surfaceVariant: Color(0xFFEBEDEF),
  onSurfaceVariant: Color(0xFFE36397),
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
    selectionColor: lightColorScheme.onPrimary.withOpacity(0.5),
    selectionHandleColor: lightColorScheme.onPrimary,
  ),
  iconTheme: const IconThemeData(
    size: 24,
  ),
);

ColorScheme debugColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.deepPurple.shade700,
  onPrimary: Colors.deepPurple.shade300,
  secondary: Colors.orange.shade700,
  onSecondary: Colors.orange.shade300,
  tertiary: Colors.green.shade700,
  onTertiary: Colors.green.shade300,
  error: Colors.red.shade700,
  onError: Colors.red.shade300,
  background: Colors.brown.shade700,
  onBackground: Colors.brown.shade300,
  surface: Colors.teal.shade700,
  onSurface: Colors.teal.shade300,
  onSurfaceVariant: Colors.tealAccent,
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
    selectionColor: debugColorScheme.onPrimary.withOpacity(0.5),
    selectionHandleColor: debugColorScheme.onPrimary,
  ),
  iconTheme: const IconThemeData(
    size: 24,
  ),
);
