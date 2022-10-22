import 'package:flutter/material.dart';

/// Options for sorting Presets on PresetsView.
enum PresetsSortOption {
  byName,
  byGame,
  byOpenedCount,
}

/// Popup sorting button for PresetsView.
class PresetsSortButton extends StatelessWidget {
  const PresetsSortButton({
    super.key,
    required this.onSelected,
    this.sortOption = PresetsSortOption.byName,
    this.sortAscending = true,
  });

  final Function(PresetsSortOption option) onSelected;
  final PresetsSortOption sortOption;
  final bool sortAscending;

  PopupMenuItem<PresetsSortOption> _buildSortItem(
    BuildContext context,
    PresetsSortOption option,
    String title,
  ) {
    var children = <Widget>[
      Expanded(
        child: Text(title),
      ),
    ];

    // Add sort direction icon for the selected sort option.
    if (option == sortOption) {
      // TODO: color and size based on context theme
      children.add(Icon(
        sortAscending ? Icons.south : Icons.north,
        color: Colors.black,
        size: 20,
      ));
    }

    return PopupMenuItem(value: option, child: Row(children: children));
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PresetsSortOption>(
      icon: const Icon(Icons.sort),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => [
        _buildSortItem(
          context,
          PresetsSortOption.byName,
          'Sort by preset name',
        ),
        _buildSortItem(
          context,
          PresetsSortOption.byGame,
          'Sort by game title',
        ),
        _buildSortItem(
          context,
          PresetsSortOption.byOpenedCount,
          'Sort by usage rate',
        ),
      ],
    );
  }
}
