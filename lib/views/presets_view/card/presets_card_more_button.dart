import 'package:flutter/material.dart';

import '../../../widgets/inkless_popup_menu_button.dart';

/// Additional action option for Preset cards.
enum PresetsCardMoreOption {
  customise,
  edit,
  remove,
}

/// Popup button for Preset cards containing additional Preset card actions.
class PresetsCardMoreButton extends StatelessWidget {
  const PresetsCardMoreButton({
    super.key,
    required this.onSelected,
    this.size,
  });

  final Function(PresetsCardMoreOption option) onSelected;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return InklessPopupMenuButton<PresetsCardMoreOption>(
      tooltip: 'Show actions',
      icon: Icon(
        Icons.more_vert,
        size: size,
      ),
      onSelected: onSelected,
      padding: const EdgeInsets.only(left: 12),
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<PresetsCardMoreOption>(
          value: PresetsCardMoreOption.customise,
          child: Text('Customise'),
        ),
        const PopupMenuItem<PresetsCardMoreOption>(
          value: PresetsCardMoreOption.edit,
          child: Text('Edit'),
        ),
        const PopupMenuItem(
          value: PresetsCardMoreOption.remove,
          child: Text('Remove'),
        ),
      ],
    );
  }
}
