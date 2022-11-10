import 'dart:convert';
import 'dart:math';

import 'package:board_aid/util/themes.dart';
import 'package:board_aid/views/customize_preset_view/customize_preset_view.dart';
import 'package:board_aid/views/presets_view/appbar/presets_appbar_about_dialog.dart';
import 'package:board_aid/views/presets_view/appbar/presets_appbar_more_button.dart';
import 'package:board_aid/views/presets_view/appbar/presets_appbar_sort_button.dart';
import 'package:board_aid/views/presets_view/card/preset_card.dart';
import 'package:board_aid/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/preset_model.dart';
import '../../table_board.dart';
import 'appbar/presets_appbar.dart';
import 'card/preset_card_more_button.dart';

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
  var sortOption = PresetsAppbarSortOption.byName;
  var sortAscending = true;
  late SharedPreferences storage;

  /// Creates a new Preset.
  void _createPreset() {
    // Create a randomised preset.
    final random = Random();
    final iconCodeIndex = random.nextInt(ThemeHelper.presetIconCodes.length);
    final colorIndex = random.nextInt(ThemeHelper.backgroundColors.length);
    var randomIconCode =
        ThemeHelper.presetIconCodes.keys.elementAt(iconCodeIndex);
    var randomColor = ThemeHelper.backgroundColors.keys.elementAt(colorIndex);
    var newPreset = PresetModel(
      name: 'Title (Tap to Edit)',
      iconCode: randomIconCode,
      backgroundColor: randomColor,
    );

    // Open Preset creation view.
    // TODO: There should be a callback for preset list update from
    // TODO: DashboardWidget (for auto-save, delayed preset creation etc.) or
    // TODO: the preset storing should be global (possibly the better solution).
    // TODO: See: https://stackoverflow.com/questions/48582963/flutter-how-to-execute-when-clicking-back-button
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardWidget(preset: newPreset),
      ),
    );

    // Save the new Preset (if not empty).
    // TODO: Drop empty presets on creation.
    presets.add(newPreset);
    _updateRenderedPresets();
    _storePresets();
  }

  /// Removes the selected Preset.
  void _removePreset(String id) async {
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
        case PresetsAppbarSortOption.byName:
          compareResult = a.name.compareTo(b.name);
          break;
        case PresetsAppbarSortOption.byGame:
          compareResult = a.game.compareTo(b.game);
          break;
        case PresetsAppbarSortOption.byOpenedCount:
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
  void _handleSortSelected(PresetsAppbarSortOption option) {
    // Reverse current sort order when the same sort option is selected.
    if (option == sortOption) {
      sortAscending = !sortAscending;
    } else {
      sortOption = option;
    }

    _updateRenderedPresets();
  }

  /// Handles additional menu actions.
  void _handleMoreSelected(PresetsAppbarMoreOption option) async {
    switch (option) {
      case PresetsAppbarMoreOption.removeAll:
        showDialog(
          context: context,
          builder: (BuildContext context) => ConfirmationDialog(
            title: 'Remove All Presets',
            message: 'Are you sure you want to remove all saved presets?',
            onConfirm: () async {
              presets.clear();
              _updateRenderedPresets();
              var storage = await SharedPreferences.getInstance();
              await storage.clear();
            },
          ),
        );
        break;
      case PresetsAppbarMoreOption.showAbout:
        showDialog(
          context: context,
          builder: (BuildContext context) => const PresetsAppbarAboutDialog(),
        );
        break;
    }
  }

  /// Handles actions from Preset show more dropdowns.
  void _handlePresetActionSelected(String id, PresetCardMoreOption option) {
    var index = presets.indexWhere((preset) => preset.id == id);
    var preset = presets[index];
    switch (option) {
      case PresetCardMoreOption.customize:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomizePresetView(
              preset: preset,
              onSave: (updatedPreset) {
                presets[index] = updatedPreset;
                _storePresets();
                _updateRenderedPresets();
              },
            ),
          ),
        );
        break;
      case PresetCardMoreOption.edit:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardWidget(preset: preset),
          ),
        );
        break;
      case PresetCardMoreOption.remove:
        showDialog(
          context: context,
          builder: (BuildContext context) => ConfirmationDialog(
            title: 'Remove Preset',
            message: 'Are you sure you want to remove ${preset.name}?',
            onConfirm: () => _removePreset(id),
          ),
        );
        break;
    }
  }

  /// Stores presets into the local storage
  void _storePresets() async {
    storage = await SharedPreferences.getInstance();
    // TODO: jsonEncode seems to throw exceptions now after icons were added.
    await storage.setString('presets', jsonEncode(presets));
  }

  /// Loads presets from local storage
  Future<void> _loadPresets() async {
    storage = await SharedPreferences.getInstance();
    setState(() {
      presets = List<PresetModel>.from(
          jsonDecode(storage.getString('presets') ?? "[]")
              .map((model) => PresetModel.fromJson(model)));
    });
    _updateRenderedPresets();
  }

  @override
  void initState() {
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardWidget(preset: preset),
                ),
              );
            },
            child: PresetCard(
              preset: preset,
              onFavouritePressed: () => _toggleFavourite(preset.id),
              onMoreSelected: (option) =>
                  _handlePresetActionSelected(preset.id, option),
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
