import 'package:flutter/material.dart';

/// Dialog with basic information about the application and its developers.
class PresetsAppbarAboutDialog extends StatelessWidget {
  const PresetsAppbarAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AboutDialog(
      applicationName: 'Board Aid',
      applicationIcon: Icon(Icons.people), // TODO: Real icon?
      applicationVersion: 'Version 1.0.0+1',
      applicationLegalese: '© The Board Aid Team',
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
              'Board Aid provides customisable presets of widgets that can be '
              'modified to satisfy all of you board game needs!'),
        ),
      ],
    );
  }
}
