import 'dart:convert';
import 'dart:math';

import 'package:board_aid/themes.dart';
import 'package:board_aid/views/presets_view/appbar/presets_more_button.dart';
import 'package:board_aid/views/presets_view/appbar/presets_sort_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/preset_model.dart';
import '../../table_board.dart';
import 'appbar/presets_appbar.dart';

/// View widget providing a grid view of all available game Presets.
class PresetsView extends StatefulWidget {
  const PresetsView({super.key});

  @override
  State<PresetsView> createState() => _PresetsViewState();
}

/// PresetsView state.
class _PresetsViewState extends State<PresetsView> {
  var presets = <PresetModel>[];
  var renderedPresets = <PresetModel>[];
  var searchText = '';
  var sortOption = PresetsSortOption.byName;
  var sortAscending = true;
  late SharedPreferences storage;

  /// Creates a new Preset.
  void _createPreset() {
    // TODO: open a new screen instead
    presets.add(PresetModel(
      name: 'Preset ${Random().nextInt(10000)}',
      game: 'LCG',
      backgroundColor: Random().nextInt(2) == 1 ? Colors.blue : Colors.red,
    ));
    _updateRenderedPresets();
    _storePresets();
  }

  // Removes the selected Preset.
  void _removePreset(String id) async {
    // TODO: add confirmation dialog
    presets.removeWhere((preset) => preset.id == id);
    _updateRenderedPresets();
    _storePresets();
    storage = await SharedPreferences.getInstance();
    storage.remove("init_$id");
    for (var s in [2, 3]) {
      storage.remove("preset_data_${id}_$s");
    }
  }

  // Toggles favourite status of the selected Preset.
  void _toggleFavourite(String id) {
    var index = presets.indexWhere((preset) => preset.id == id);
    presets[index].isFavourite = !presets[index].isFavourite;
    _updateRenderedPresets();
    _storePresets();
  }

  /// Updates the ordered and filtered list of rendered Presets.
  void _updateRenderedPresets() {
    // Copy the list of all Presets.
    var updatedPresets = presets.toList();

    // Apply the search filter.
    if (searchText != '') {
      updatedPresets.retainWhere((preset) {
        var searched = preset.name.toLowerCase() + preset.game.toLowerCase();
        return searched.contains(searchText);
      });
    }

    // Sort the remainder.
    updatedPresets.sort((a, b) {
      if (a.isFavourite != b.isFavourite) {
        // Favourites should always be on top.
        return a.isFavourite ? -1 : 1;
      }

      // Apply the selected sorting method.
      int compareResult;
      switch (sortOption) {
        case PresetsSortOption.byName:
          compareResult = a.name.compareTo(b.name);
          break;
        case PresetsSortOption.byGame:
          compareResult = a.game.compareTo(b.game);
          break;
        case PresetsSortOption.byOpenedCount:
          compareResult = a.openedCount.compareTo(b.openedCount);
          break;
      }

      // Reverse the order if descending.
      return sortAscending ? compareResult : -compareResult;
    });

    setState(() {
      renderedPresets = updatedPresets;
    });
  }

  /// Handles changes in the searched text.
  void _handleSearchChanged(String searched) {
    searchText = searched;
    _updateRenderedPresets();
  }

  /// Handles changes in sort order and direction.
  void _handleSortSelected(PresetsSortOption option) {
    // Reverse current sort order when the same sort option is selected.
    if (option == sortOption) {
      sortAscending = !sortAscending;
    } else {
      sortOption = option;
    }

    _updateRenderedPresets();
  }

  /// Handles additional menu actions.
  void _handleMoreSelected(PresetsMoreOption option) async {
    switch (option) {
      case PresetsMoreOption.removeAll:
        // TODO: add confirmation dialog
        presets.clear();
        _updateRenderedPresets();
        break;
      case PresetsMoreOption.showAbout:
        // TODO: show "About application" dialog (probably just a copy-paste of
        // TODO: app description from app store)
        break;
      case PresetsMoreOption.clearStorage:
        var storage = await SharedPreferences.getInstance();
        await storage.clear();
        break;
    }
  }

  /// Stores presets into the local storage
  void _storePresets() async {
    storage = await SharedPreferences.getInstance();
    await storage.setString('presets', jsonEncode(presets));
  }

  /// Loads presets from local storage
  Future<void> _loadPresets() async {
    storage = await SharedPreferences.getInstance();
    setState(() {
      presets = List<PresetModel>.from(
          jsonDecode(storage.getString('presets') ?? "[]").map(
                  (model)=> PresetModel.fromJson(model)
          )
      );
    });
    _updateRenderedPresets();
  }

  @override
  void initState(){
    super.initState();
    _loadPresets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PresetsAppbar(
        onSearchChanged: _handleSearchChanged,
        onSortSelected: _handleSortSelected,
        onMoreSelected: _handleMoreSelected,
        sortOption: sortOption,
        sortAscending: sortAscending,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(ThemeHelper.cardSpacing()),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: ThemeHelper.cardSpacing() / 2,
          mainAxisSpacing: ThemeHelper.cardSpacing() / 2,
        ),
        itemCount: renderedPresets.length,
        itemBuilder: (BuildContext context, index) {
          var preset = renderedPresets[index];
          return Card(
            elevation: ThemeHelper.cardElevation(),
            color: preset.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeHelper.borderRadius()),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DashboardWidget(preset: preset)));
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(
                            image: preset.image,
                            width: 30,
                            height: 30,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              preset.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            preset.game,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkResponse(
                              radius: 20,
                              onTap: () => _toggleFavourite(preset.id),
                              child: Icon(
                                preset.isFavourite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: InkResponse(
                              radius: 20,
                              // TODO: add real dropdown menu, not just delete
                              onTap: () => _removePreset(preset.id),
                              child: Icon(
                                Icons.more_vert,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPreset,
        tooltip: 'New game preset',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
