import 'package:flutter/material.dart';

/// Additional action option for PresetsView.
enum PresetsAppbarMoreOption {
  removeAll,
  showAbout,
  // TODO: Remove before production.
  clearStorage,
}

/// Popup button for PresetsView containing additional menu options.
class PresetsAppbarMoreButton extends StatelessWidget {
  const PresetsAppbarMoreButton({super.key, required this.onSelected});

  final Function(PresetsAppbarMoreOption option) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PresetsAppbarMoreOption>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Show menu',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<PresetsAppbarMoreOption>(
          value: PresetsAppbarMoreOption.removeAll,
          child: Text('Remove all presets'),
        ),
        const PopupMenuItem<PresetsAppbarMoreOption>(
          value: PresetsAppbarMoreOption.showAbout,
          child: Text('About'),
        ),
        const PopupMenuItem(
          value: PresetsAppbarMoreOption.clearStorage,
          child: Text('DEV - Clear storage'),
        ),
      ],
    );
  }
}
