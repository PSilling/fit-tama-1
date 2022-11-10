import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

import 'views/presets_view/presets_view.dart';

/// Application entrypoint.
void main() {
  runApp(const BoardAidApp());
}

/// Root application widget of Board Aid.
class BoardAidApp extends StatelessWidget {
  const BoardAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Board Aid',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const PresetsView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
