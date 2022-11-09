import 'package:flutter/material.dart';

/// Additional action option for PresetsView.
enum PresetsMoreOption {
  removeAll,
  showAbout,
  clearStorage,
}

/// Popup button for PresetsView containing additional menu options.
class PresetsMoreButton extends StatelessWidget {
  const PresetsMoreButton({super.key, required this.onSelected});

  final Function(PresetsMoreOption option) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PresetsMoreOption>(
      color: Theme.of(context).colorScheme.secondary,
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<PresetsMoreOption>(
          value: PresetsMoreOption.removeAll,
          child: Text(
            'Remove all presets',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
        PopupMenuItem<PresetsMoreOption>(
          value: PresetsMoreOption.removeAll,
          child: Text(
            'About',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
        PopupMenuItem(
            value: PresetsMoreOption.clearStorage,
            child: Text(
              'DEV - Clear storage',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ))
      ],
    );
  }
}
