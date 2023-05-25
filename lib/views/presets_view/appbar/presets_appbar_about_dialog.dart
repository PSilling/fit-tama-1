import 'package:flutter/material.dart';
import 'package:board_aid/util/themes.dart';

/// Dialog with basic information about the application and its developers.
class PresetsAppbarAboutDialog extends StatelessWidget {
  const PresetsAppbarAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: Typography.whiteCupertino.apply(
          bodyColor: Colors.black,
          displayColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
      child: const AboutDialog(
        applicationName: 'Board Aid',
        applicationIcon: Image(image: AssetImage('assets/icon.png')),
        applicationVersion: 'Version 1.1.0+1',
        applicationLegalese: '© The Board Aid Team',
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Board Aid provides customisable presets of widgets that can be '
                  'modified to satisfy all of you board game needs!',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
