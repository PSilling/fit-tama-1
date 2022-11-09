import 'package:flutter/material.dart';

import 'presets_appbar_more_button.dart';
import 'presets_appbar_search_input.dart';
import 'presets_appbar_sort_button.dart';

/// Application bar for PresetsView.
class PresetsAppbar extends StatefulWidget implements PreferredSizeWidget {
  const PresetsAppbar({
    super.key,
    required this.onSearchChanged,
    required this.onSortSelected,
    required this.onMoreSelected,
    this.sortOption = PresetsAppbarSortOption.byName,
    this.sortAscending = true,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;
  final Function(String searched) onSearchChanged;
  final Function(PresetsAppbarSortOption option) onSortSelected;
  final Function(PresetsAppbarMoreOption option) onMoreSelected;
  final PresetsAppbarSortOption sortOption;
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
        title: PresetsAppbarSearchInput(
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
        PresetsAppbarSortButton(
          onSelected: widget.onSortSelected,
          sortOption: widget.sortOption,
          sortAscending: widget.sortAscending,
        ),
        PresetsAppbarMoreButton(onSelected: widget.onMoreSelected),
      ],
    );
  }
}
