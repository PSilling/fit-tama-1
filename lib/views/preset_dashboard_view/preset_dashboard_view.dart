import 'dart:async';
import 'dart:math';

import 'package:board_aid/util/themes.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import './add_widget_dialog.dart';
import './remove_widget_dialog.dart';
import '../../models/preset_model.dart';
import 'colored_dashboard_item.dart';
import 'preset_widgets_storage.dart';

class PresetDashboardView extends StatefulWidget {
  final PresetModel preset;
  final Function(
    PresetModel updatedPreset,
    Map<String, dynamic> widgets,
  )? onClose;

  const PresetDashboardView({
    super.key,
    required this.preset,
    this.onClose,
  });
  @override
  State<PresetDashboardView> createState() => _PresetDashboardViewState();
}

class _PresetDashboardViewState extends State<PresetDashboardView> {
  ///
  final ScrollController scrollController = ScrollController();

  late PresetWidgetsStorage storage;

  ///
  late DashboardItemController<ColoredDashboardItem> itemController;

  int? slot;
  bool editVisible = false;
  late FocusNode textFocusNode;
  late String nameEdit;

  @override
  void initState() {
    super.initState();
    storage = PresetWidgetsStorage(widget.preset.id);
    itemController = DashboardItemController<ColoredDashboardItem>.withDelegate(
        itemStorageDelegate: storage);
    textFocusNode = FocusNode();
    nameEdit = widget.preset.name;
  }

  void setSlot() {
    slot = 2;
    setState(() {});
  }

  /// Handles storage and callbacks on navigator pop.
  Future<bool> _onWillPop() {
    // Store the preset.
    storage.onItemsUpdated([], slot!);

    // Call the callback if given.
    if (widget.onClose != null) {
      widget.onClose!(widget.preset, storage.widgets ?? {});
    }
    textFocusNode.dispose();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    slot = 2;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Stack(
            children: [
              TextFormField(
                focusNode: textFocusNode,
                style: Theme.of(context).textTheme.titleLarge,
                cursorColor: ThemeHelper.dialogForeground(context),
                decoration: ThemeHelper.dialogInputDecoration(
                  context,
                  hasBorder: false,
                  hasPadding: false
                ),
                initialValue: widget.preset.name,
                textInputAction: TextInputAction.done,
                onTap: () => textFocusNode.requestFocus(),
                onChanged: (value) {nameEdit = value;},
                onEditingComplete: () {
                  widget.preset.name = nameEdit;
                  textFocusNode.unfocus();
                  setState(() {});
                },
              ),
            ]
          ),
          actions: [
            Visibility(
              visible: editVisible,
                child: IconButton(
                  onPressed: () {clear(context);},
                  icon: const Icon(Icons.delete)
                ),
            ),
            IconButton(
              onPressed: () {
                editVisible = !editVisible;
                itemController.isEditing = !itemController.isEditing;
                storage.setWidgetsEditing(itemController.isEditing);
                if (itemController.isEditing == false) {
                  storage.onItemsUpdated([], slot!);
                }
                setState(() {});
              },
              icon: editVisible
                ? const Icon(Icons.edit_off)
                : const Icon(Icons.edit),
            ),
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
            scrollController: scrollController,
            dashboardItemController: itemController,
            slotCount: slot!,
            physics: const RangeMaintainingScrollPhysics(),
            dragStartBehavior: DragStartBehavior.down,
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
              paintBackgroundLines: true,
              fillEditingBackground: true,
              editAnimationAngle: 0.5 * pi / 180,
              editAnimationSync: false,
              resizeCursorSide: 0, // when set to 0 user cannot change the shape of the widgets
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 300),
              backgroundStyle: EditModeBackgroundStyle(
                lineColor: Colors.transparent,
                fillRadius: ThemeHelper.borderRadius(),
              ),
            ),
            itemBuilder: (ColoredDashboardItem item) {
              //print(storage.localItems![slot]![item.identifier]);
              return Stack(children: [
                storage.widgets![item.identifier],
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
                        color: ThemeHelper.cardForegroundColor(context),
                      )
                    )
                  )
              ]);
            }),
        ),
        floatingActionButton: AnimatedSlide(
          curve: editVisible ? Curves.ease : Curves.easeInExpo,
          duration: const Duration(milliseconds: 300),
          offset: editVisible ? Offset.zero : const Offset(0, 2),
          child: FloatingActionButton(
            backgroundColor: ThemeHelper.floaterBackgroundColor(context),
            foregroundColor: ThemeHelper.floaterForegroundColor(context),
            onPressed: () {add(context);},
            tooltip: 'Add new widget',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Future<void> add(BuildContext context) async {
    var res = await showDialog(
        context: context,
        builder: (c) {
          return const AddWidgetDialog();
        });

    if (res != null) {
      itemController.add(ColoredDashboardItem(
          width: res[1],
          height: 1,
          identifier: Random().nextInt(1000).toString() +
              DateTime.now().microsecondsSinceEpoch.toString(),
          minWidth: res[1],
          minHeight: 1,
          maxWidth: 2,
          maxHeight: 1,
          type: res[0],
          data: storage.defaultData[res[0]]!));
    }
  }

  Future<void> clear(BuildContext context) async {
    var res = await showDialog(
        context: context,
        builder: (c) {
          return const RemoveWidgetDialog();
        });

    if (res != null && res) {
      itemController.clear();
    }
  }
}
