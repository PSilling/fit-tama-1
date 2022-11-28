import 'dart:convert';
import 'dart:math';

import 'package:board_aid/util/themes.dart';
import 'package:board_aid/views/edit_views/customize_preset_view.dart';
import 'package:board_aid/views/presets_view/appbar/presets_appbar_about_dialog.dart';
import 'package:board_aid/views/presets_view/appbar/presets_appbar_more_button.dart';
import 'package:board_aid/views/presets_view/appbar/presets_appbar_sort_button.dart';
import 'package:board_aid/views/presets_view/card/preset_card.dart';
import 'package:board_aid/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/preset_model.dart';
import '../preset_dashboard_view/preset_dashboard_view.dart';
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
    final colorIndex = random.nextInt(ThemeHelper.cardBackgroundColors.length);
    var randomIconCode =
        ThemeHelper.presetIconCodes.keys.elementAt(iconCodeIndex);
    var randomColor =
        ThemeHelper.cardBackgroundColors.keys.elementAt(colorIndex);
    var newPreset = PresetModel(
      name: 'Title (Tap to Edit)',
      iconCode: randomIconCode,
      backgroundColor: randomColor,
    );

    // Open Preset creation view.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PresetDashboardView(
          preset: newPreset,
          onClose: (updatedPreset, widgets) {
            // Save the new Preset (if not empty).
            if (widgets.isNotEmpty) {
              presets.add(updatedPreset);
              _updateRenderedPresets();
              _storePresets();
            } else {
              _removePreset(updatedPreset.id);
            }
          },
        ),
      ),
    );
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
          compareResult = b.openedCount.compareTo(a.openedCount);
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

  /// Updates preset state on preset dashboard view close.
  void _handleExistingPresetClose(
    PresetModel updatedPreset,
    Map<String, dynamic> _,
  ) {
    // Increase preset usage count.
    updatedPreset.openedCount++;

    // Save the preset.
    var index = presets.indexWhere((preset) => preset.id == updatedPreset.id);
    presets[index] = updatedPreset;
    _storePresets();
    _updateRenderedPresets();
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
                  builder: (context) => PresetDashboardView(
                    preset: preset,
                    onClose: _handleExistingPresetClose,
                  ),
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
        backgroundColor: ThemeHelper.floaterBackgroundColor(context),
        foregroundColor: ThemeHelper.floaterForegroundColor(context),
        onPressed: _createPreset,
        tooltip: 'New game preset',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
