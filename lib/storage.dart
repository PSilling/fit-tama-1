import 'dart:async';
import 'dart:convert';

import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './widgets/counter_widget/counter_widget_data.dart';
import './widgets/dice_widget/dice_widget_data.dart';
import './widgets/timer_widget/timer_widget_data.dart';
import './data_widget.dart';

class ColoredDashboardItem extends DashboardItem {
  ColoredDashboardItem(
      {this.color,
      required int width,
      required int height,
      required String identifier,
      this.type,  //TODO - set required
      this.data,  //TODO - set required
      int minWidth = 1,
      int minHeight = 1,
      int? maxHeight = 1,
      int? maxWidth = 1,
      int? startX,
      int? startY})
      : super(
            startX: startX,
            startY: startY,
            width: width,
            height: height,
            identifier: identifier,
            maxHeight: maxHeight,
            maxWidth: maxWidth,
            minWidth: minWidth,
            minHeight: minHeight);

  ColoredDashboardItem.fromMap(Map<String, dynamic> map)
      : color = map["color"] != null ? Color(map["color"]) : null,
        type = map['type'],
        data = map['data'],
        super.withLayout(map["item_id"], ItemLayout.fromMap(map["layout"]));

  Color? color;
  String? type;
  String? data;

  @override
  Map<String, dynamic> toMap() {
    var sup = super.toMap();
    if (color != null) {
      sup["color"] = color?.value;
    }
    if (type != null){
      sup['type'] = type;
    }
    if (data != null) {
      sup["data"] = data;
    }
    return sup;
  }
}

class MyItemStorage extends DashboardItemStorageDelegate<ColoredDashboardItem>{

  MyItemStorage(this.presetLink);

  String presetLink;
  late SharedPreferences _preferences;
  final List<int> _slotCounts = [2, 3];
  Map<int, Map<String, ColoredDashboardItem>>? _localItems;
  Map<String, DataWidget>? widgets;

  final Map<int, List<ColoredDashboardItem>> _default = {
    2: <ColoredDashboardItem>[
      ColoredDashboardItem(
        color: Colors.blue,
        width: 1,
        height: 1,
        identifier: 'counter',
        startX: 3,
        startY: 1,
        type: 'counter',
        data: jsonEncode(CounterWidgetData(
            name: "Round",
            isUneven: false,
            scale: List<int>.generate(10, (i) => i + 1),
            defaultIndex: 2,
            isLeftDeath: false,
            isRightDeath: false
        ))
      ),
      ColoredDashboardItem(
        width: 1,
        height: 1,
        identifier: 'dice',
        startX: 1,
        startY: 0,
        type: 'dice',
        data: jsonEncode(DiceWidgetData(
            name: 'Dice',
            numberOfDice: 2,
            numberOfSides: 2
        ))
      ),
      ColoredDashboardItem(
        width: 1,
        height: 1,
        identifier: 'timer',
        startX: 0,
        startY: 1,
        type: 'timer',
        data: jsonEncode(TimerWidgetData(
            name: 'Timer',
            initialTime: 90
        ))
      )
    ],
    3: <ColoredDashboardItem>[],
  };

  @override
  FutureOr<List<ColoredDashboardItem>> getAllItems(int slotCount) {
    try {
      if (_localItems != null) {
        return _localItems![slotCount]!.values.toList();
      }

      return Future.microtask(() async {
        _preferences = await SharedPreferences.getInstance();

        var init = _preferences.getBool("init_$presetLink") ?? false;
        //var init = false;

        if (!init) {
          _localItems = {
            for (var s in _slotCounts)
              s: _default[s]!
                  .asMap()
                  .map((key, value) => MapEntry(value.identifier, value))
          };

          for (var s in _slotCounts) {
            await _preferences.setString(
                "preset_data_${presetLink}_$s",
                json.encode(_default[s]!.asMap().map((key, value) =>
                    MapEntry(value.identifier, value.toMap()))));
          }

          await _preferences.setBool("init_$presetLink", true);
        }

        var js = json.decode(_preferences.getString(
            "preset_data_${presetLink}_$slotCount")!);

        _localItems = {
          slotCount: {
            for (var e in js!.values.map((value) =>
                ColoredDashboardItem.fromMap(value)).toList()) e.identifier : e
          }
        };

        widgets = {
            for (var e in _localItems![slotCount]!.keys)
              e : DataWidget(key: GlobalKey(), item: _localItems![slotCount]![e]!)
        };

        return js!.values
            .map<ColoredDashboardItem>(
                (value) => ColoredDashboardItem.fromMap(value))
            .toList();
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  FutureOr<void> onItemsUpdated(
      List<ColoredDashboardItem> items, int slotCount) async {

    for (var item in items) {
      _localItems?[slotCount]?[item.identifier] = item;
    }

    var js = json.encode(_localItems![slotCount]!
        .map((key, value) => MapEntry(key, value.toMap())));

    await _preferences.setString("preset_data_${presetLink}_$slotCount", js);
  }

  @override
  FutureOr<void> onItemsAdded(
      List<ColoredDashboardItem> items, int slotCount) async {
    for (var s in _slotCounts) {
      for (var i in items) {
        _localItems![s]?[i.identifier] = i;
        widgets![i.identifier] = DataWidget(key: GlobalKey(), item: i);
      }

      await _preferences.setString(
          "preset_data_${presetLink}_$s",
          json.encode(_localItems![s]!
              .map((key, value) => MapEntry(key, value.toMap()))));
    }
  }

  @override
  FutureOr<void> onItemsDeleted(
      List<ColoredDashboardItem> items, int slotCount) async {
    for (var s in _slotCounts) {
      for (var i in items) {
        _localItems![s]?.remove(i.identifier);
        widgets?.remove(i.identifier);
      }

      await _preferences.setString(
          "preset_data_${presetLink}_$s",
          json.encode(_localItems![s]!
              .map((key, value) => MapEntry(key, value.toMap()))));
    }
  }

  Future<void> clear() async {
    for (var s in _slotCounts) {
      _localItems?[s]?.clear();
      await _preferences.remove("preset_data_${presetLink}_$s");
    }
    _localItems = null;
    widgets = null;
    await _preferences.setBool("init_$presetLink", false);
  }

  @override
  bool get layoutsBySlotCount => true;

  @override
  bool get cacheItems => true;
}
