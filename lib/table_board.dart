import 'dart:async';
import 'dart:math';

import 'package:board_aid/util/themes.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';

import './storage.dart';
import 'add_widget_dialog.dart';
import 'models/preset_model.dart';

class DashboardWidget extends StatefulWidget {
  final PresetModel preset;

  const DashboardWidget({super.key, required this.preset});
  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  ///
  final ScrollController scrollController = ScrollController();

  late MyItemStorage storage;

  ///
  late DashboardItemController<ColoredDashboardItem> itemController;

  int? slot;

  @override
  void initState() {
    super.initState();
    storage = MyItemStorage(widget.preset.id);
    itemController = DashboardItemController<ColoredDashboardItem>.withDelegate(
        itemStorageDelegate: storage);
  }

  setSlot() {
    slot = 2;
    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    slot = 2;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.preset.name),
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
                storage.setWidgetsEditing(itemController.isEditing);
                if (itemController.isEditing == false) {
                  storage.onItemsUpdated([], slot!);
                }
              },
              icon: const Icon(Icons.edit)),
        ],
      ),
      body: SafeArea(
        child: Dashboard<ColoredDashboardItem>(
            shrinkToPlace: false,
            slideToTop: false,
            absorbPointer: false,
            // HACK: Values must be 50% larger compared to those in presets_view to match for some reason.
            padding: EdgeInsets.all(ThemeHelper.cardSpacing()) * 1.5,
            horizontalSpace: ThemeHelper.cardSpacing() * 1.5,
            verticalSpace: ThemeHelper.cardSpacing() * 1.5,
            slotAspectRatio: 1,
            animateEverytime: true,
            scrollController: ScrollController(),
            dashboardItemController: itemController,
            slotCount: slot!,
            errorPlaceholder: (e, s) {
              return Text("$e , $s");
            },
            itemStyle: ItemStyle(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: ThemeHelper.cardElevation(),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeHelper.borderRadius()))),
            editModeSettings: EditModeSettings(
              paintBackgroundLines: false,
              fillEditingBackground: false,
              resizeCursorSide:
                  0, // when set to 0 user cannot change the shape of the widgets
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 300),
            ),
            itemBuilder: (ColoredDashboardItem item) {
              //print(storage.localItems![slot]![item.identifier]);
              return Stack(children: [
                storage.widgets![item.identifier]!,
                if (itemController.isEditing)
                  Positioned(
                      right: 5,
                      top: 5,
                      child: InkResponse(
                          radius: 20,
                          onTap: () {
                            itemController.delete(item.identifier);
                          },
                          child: Icon(
                            Icons.clear,
                            color: Theme.of(context).colorScheme.onSurface,
                          )))
              ]);
            }),
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
          color: Colors.blue,
          width: 1,
          height: 1,
          identifier: Random().nextInt(1000).toString() +
              DateTime.now().microsecondsSinceEpoch.toString(),
          minWidth: 1,
          minHeight: 1,
          maxWidth: 2,
          maxHeight: 1,
          type: res,
          data: storage.defaultData[res]!));
    }
  }
}
