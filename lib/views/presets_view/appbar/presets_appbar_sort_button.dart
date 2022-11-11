import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

/// Options for sorting Presets on PresetsView.
enum PresetsAppbarSortOption {
  byName,
  byGame,
  byOpenedCount,
}

/// Popup sorting button for PresetsView.
class PresetsAppbarSortButton extends StatelessWidget {
  const PresetsAppbarSortButton({
    super.key,
    required this.onSelected,
    this.sortOption = PresetsAppbarSortOption.byName,
    this.sortAscending = true,
  });

  final Function(PresetsAppbarSortOption option) onSelected;
  final PresetsAppbarSortOption sortOption;
  final bool sortAscending;

  /// Builds an sort option item based on text and sort direction arrow.
  PopupMenuItem<PresetsAppbarSortOption> _buildSortItem(
    BuildContext context,
    PresetsAppbarSortOption option,
    String title,
  ) {
    var children = <Widget>[
      Expanded(
        child: Text(
          title,
          style: ThemeHelper.popUpTextStyle(context),
        ),
      ),
    ];

    // Add sort direction icon for the selected sort option.
    if (option == sortOption) {
      children.add(Icon(
        sortAscending ? Icons.south : Icons.north,
        color: Theme.of(context).colorScheme.onSecondary,
      ));
    }

    return PopupMenuItem(value: option, child: Row(children: children));
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PresetsAppbarSortOption>(
      color: ThemeHelper.popUpBackgroundColor(context),
      icon: const Icon(Icons.sort),
      tooltip: 'Show sort options',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => [
        _buildSortItem(
          context,
          PresetsAppbarSortOption.byName,
          'Sort by preset name',
        ),
        _buildSortItem(
          context,
          PresetsAppbarSortOption.byGame,
          'Sort by game title',
        ),
        _buildSortItem(
          context,
          PresetsAppbarSortOption.byOpenedCount,
          'Sort by usage rate',
        ),
      ],
    );
  }
}
