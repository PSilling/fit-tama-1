import 'package:flutter/material.dart';

import 'views/presets_view/presets_view.dart';

/// Application entrypoint.
void main() {
  runApp(const BoardAidApp());
}

/// Root application widget of Board Aid.
// TODO: maybe setup a global theme?
class BoardAidApp extends StatelessWidget {
  const BoardAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Board Aid',
      home: const PresetsView(),
      theme: Theme.of(context),
      debugShowCheckedModeBanner: false,
    );
  }
}
