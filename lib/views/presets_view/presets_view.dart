import 'dart:async';
import 'dart:math';

import 'package:board_aid/views/presets_view/appbar/presets_more_button.dart';
import 'package:board_aid/views/presets_view/appbar/presets_sort_button.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';

import '../../add_widget_dialog.dart';
import '../../data_widget.dart';
import '../../models/preset_model.dart';
import '../../storage.dart';
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

  /// Creates a new Preset.
  void _createPreset() {
    // TODO: open a new screen instead
    presets.add(PresetModel(
      name: 'Preset ${Random().nextInt(10000)}',
      game: 'LCG',
      backgroundColor: Random().nextInt(2) == 1 ? Colors.blue : Colors.red,
    ));
    _updateRenderedPresets();
  }

  // Removes the selected Preset.
  void _removePreset(String id) {
    // TODO: add confirmation dialog
    presets.removeWhere((preset) => preset.id == id);
    _updateRenderedPresets();
  }

  // Toggles favourite status of the selected Preset.
  void _toggleFavourite(String id) {
    var index = presets.indexWhere((preset) => preset.id == id);
    presets[index].isFavourite = !presets[index].isFavourite;
    _updateRenderedPresets();
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
  void _handleMoreSelected(PresetsMoreOption option) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PresetsAppbar(
        onSearchChanged: _handleSearchChanged,
        onSortSelected: _handleSortSelected,
        onMoreSelected: _handleMoreSelected,
        sortOption: sortOption,
        sortAscending: sortAscending,
      ),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: renderedPresets.length,
          itemBuilder: (BuildContext context, index) {
            var preset = renderedPresets[index];
            return Card(
              elevation: 6,
              color: preset.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: InkResponse(
                                radius: 20,
                                // TODO: add real dropdown menu, not just delete
                                onTap: () => _removePreset(preset.id),
                                child: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 20,
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

// TODO: move these widgets and cleanup the code
class DashboardWidget extends StatefulWidget {
  final PresetModel preset;

  const DashboardWidget({super.key, required this.preset});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ScrollController scrollController = ScrollController();

  late var itemController =
      DashboardItemController<ColoredDashboardItem>.withDelegate(
          itemStorageDelegate: storage);

  bool refreshing = false;

  var storage = MyItemStorage();

  int? slot;

  setSlot() {
    setState(() {
      slot = 2;
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    slot = 2;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('placeholder'), // Text(widget.itemData.name),
        actions: [
          IconButton(
              onPressed: () {
                itemController.clear();
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () {
                add(context);
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                itemController.isEditing = !itemController.isEditing;
                setState(() {});
              },
              icon: const Icon(Icons.edit)),
        ],
      ),
      body: SafeArea(
        child: Dashboard<ColoredDashboardItem>(
          shrinkToPlace: false,
          slideToTop: true,
          absorbPointer: false,
          padding: const EdgeInsets.all(8),
          horizontalSpace: 8,
          verticalSpace: 8,
          slotAspectRatio: 1,
          animateEverytime: true,
          scrollController: ScrollController(),
          dashboardItemController: itemController,
          slotCount: slot!,
          errorPlaceholder: (e, s) {
            return Text("$e , $s");
          },
          itemStyle: ItemStyle(
              color: Colors.transparent,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          editModeSettings: EditModeSettings(
            paintBackgroundLines: false,
            fillEditingBackground: false,
            resizeCursorSide:
                0, // when set to 0 user cannot change the shape of the widgets
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 300),
          ),
          itemBuilder: (ColoredDashboardItem item) {
            var layout = item.layoutData;

            if (item.data != null) {
              return DataWidget(
                item: item,
              );
            }

            return Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(10)),
                  child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Text(
                        "Subject to change \n ID: ${item.identifier}\n${[
                          "x: ${layout.startX}",
                          "y: ${layout.startY}",
                          "w: ${layout.width}",
                          "h: ${layout.height}",
                          if (layout.minWidth != 1) "minW: ${layout.minWidth}",
                          if (layout.minHeight != 1)
                            "minH: ${layout.minHeight}",
                          if (layout.maxWidth != null)
                            "maxW: ${layout.maxWidth}",
                          if (layout.maxHeight != null)
                            "maxH : ${layout.maxHeight}"
                        ].join("\n")}",
                        style: const TextStyle(color: Colors.white),
                      )),
                ),
                if (itemController.isEditing)
                  Positioned(
                      right: 5,
                      top: 5,
                      child: InkResponse(
                          radius: 20,
                          onTap: () {
                            itemController.delete(item.identifier);
                          },
                          child: const Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 20,
                          )))
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> add(BuildContext context) async {
    var res = await showDialog(
        context: context,
        builder: (c) {
          return const AddDialog();
        });

    if (res != null) {
      itemController.add(ColoredDashboardItem(
          color: res[6],
          width: res[0],
          height: res[1],
          identifier: (Random().nextInt(100000) + 4).toString(),
          minWidth: res[2],
          minHeight: res[3],
          maxWidth: res[4] == 0 ? null : res[4],
          maxHeight: res[5] == 0 ? null : res[5]));
    }
  }
}
