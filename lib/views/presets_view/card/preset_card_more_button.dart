import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

import '../../../widgets/resizable_popup_menu_button.dart';

/// Additional action option for Preset cards.
enum PresetCardMoreOption {
  customize,
  edit,
  remove,
}

/// Popup button for Preset cards containing additional Preset card actions.
class PresetCardMoreButton extends StatelessWidget {
  const PresetCardMoreButton({
    super.key,
    required this.onSelected,
    this.size,
    this.enabled = true,
  });

  final Function(PresetCardMoreOption option) onSelected;
  final double? size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ResizablePopupMenuButton<PresetCardMoreOption>(
      color: ThemeHelper.popUpBackgroundColor(context),
      tooltip: 'Show actions',
      icon: Icon(
        Icons.more_vert,
        size: size,
        color: ThemeHelper.cardForegroundColor(context),
      ),
      onSelected: onSelected,
      padding: const EdgeInsets.only(left: 12),
      position: PopupMenuPosition.under,
      enabled: enabled,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<PresetCardMoreOption>(
          value: PresetCardMoreOption.customize,
          child: Text(
            'Customize',
            style: ThemeHelper.popUpTextStyle(context),
          ),
        ),
        PopupMenuItem<PresetCardMoreOption>(
          value: PresetCardMoreOption.edit,
          child: Text(
            'Edit',
            style: ThemeHelper.popUpTextStyle(context),
          ),
        ),
        PopupMenuItem(
          value: PresetCardMoreOption.remove,
          child: Text(
            'Remove',
            style: ThemeHelper.popUpTextStyle(context),
          ),
        ),
      ],
    );
  }
}
