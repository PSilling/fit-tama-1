import 'package:flutter/material.dart';

import 'presets_more_button.dart';
import 'presets_search_input.dart';
import 'presets_sort_button.dart';

/// Application bar for PresetsView.
class PresetsAppbar extends StatefulWidget implements PreferredSizeWidget {
  const PresetsAppbar({
    super.key,
    required this.onSearchChanged,
    required this.onSortSelected,
    required this.onMoreSelected,
    this.sortOption = PresetsSortOption.byName,
    this.sortAscending = true,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;
  final Function(String searched) onSearchChanged;
  final Function(PresetsSortOption option) onSortSelected;
  final Function(PresetsMoreOption option) onMoreSelected;
  final PresetsSortOption sortOption;
  final bool sortAscending;

  @override
  State<PresetsAppbar> createState() => _PresetsAppbarState();
}

class _PresetsAppbarState extends State<PresetsAppbar> {
  var searchOpen = false;

  /// Toggles visibility of the search bar, clearing search text when closing.
  void _toggleSearch() {
    if (searchOpen) {
      widget.onSearchChanged('');
    }

    setState(() {
      searchOpen = !searchOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (searchOpen) {
      return AppBar(
        title: PresetsSearchInput(
          onSearchChanged: widget.onSearchChanged,
          onCancel: _toggleSearch,
        ),
      );
    }

    return AppBar(
      title: const Text('Game Presets'),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: const Icon(Icons.search),
        ),
        PresetsSortButton(
          onSelected: widget.onSortSelected,
          sortOption: widget.sortOption,
          sortAscending: widget.sortAscending,
        ),
        PresetsMoreButton(onSelected: widget.onMoreSelected),
      ],
    );
  }
}
