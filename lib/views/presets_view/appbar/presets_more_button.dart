import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

/// Additional action option for PresetsView.
enum PresetsMoreOption {
  removeAll,
  showAbout,
}

/// Popup button for PresetsView containing additional menu options.
class PresetsMoreButton extends StatelessWidget {
  const PresetsMoreButton({super.key, required this.onSelected});

  final Function(PresetsMoreOption option) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PresetsMoreOption>(
      color: ThemeHelper.popUpBackgroundColor(context),
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<PresetsMoreOption>(
          value: PresetsMoreOption.removeAll,
          child: Text(
            'Remove all presets',
            style: ThemeHelper.popUpTextStyle(context),
          ),
        ),
        PopupMenuItem<PresetsMoreOption>(
          value: PresetsMoreOption.removeAll,
          child: Text(
            'About',
            style: ThemeHelper.popUpTextStyle(context),
          ),
        ),
      ],
    );
  }
}
