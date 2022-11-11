import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

/// Additional action option for PresetsView.
enum PresetsAppbarMoreOption {
  removeAll,
  showAbout,
}

/// Popup button for PresetsView containing additional menu options.
class PresetsAppbarMoreButton extends StatelessWidget {
  const PresetsAppbarMoreButton({super.key, required this.onSelected});

  final Function(PresetsAppbarMoreOption option) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PresetsAppbarMoreOption>(
      color: ThemeHelper.popUpBackgroundColor(context),
      icon: const Icon(Icons.more_vert),
      tooltip: 'Show menu',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<PresetsAppbarMoreOption>(
          value: PresetsAppbarMoreOption.removeAll,
          child: Text(
            'Remove all presets',
            style: ThemeHelper.popUpTextStyle(context),
          ),
        ),
        PopupMenuItem<PresetsAppbarMoreOption>(
          value: PresetsAppbarMoreOption.showAbout,
          child: Text(
            'About',
            style: ThemeHelper.popUpTextStyle(context),
          ),
        ),
      ],
    );
  }
}
