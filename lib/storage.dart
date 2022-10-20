import 'dart:async';
import 'dart:convert';

import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColoredDashboardItem extends DashboardItem {
  ColoredDashboardItem(
      {this.color,
      required int width,
      required int height,
      required String identifier,
      this.data,
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
        data = map["data"],
        super.withLayout(map["item_id"], ItemLayout.fromMap(map["layout"]));

  Color? color;

  String? data;

  @override
  Map<String, dynamic> toMap() {
    var sup = super.toMap();
    if (color != null) {
      sup["color"] = color?.value;
    }
    if (data != null) {
      sup["data"] = data;
    }
    return sup;
  }
}

class MyItemStorage extends DashboardItemStorageDelegate<ColoredDashboardItem> {
  late SharedPreferences _preferences;

  final List<int> _slotCounts = [2, 3];

  final Map<int, List<ColoredDashboardItem>> _default = {
    2: <ColoredDashboardItem>[],
    3: <ColoredDashboardItem>[],
  };

  Map<int, Map<String, ColoredDashboardItem>>? _localItems;

  @override
  FutureOr<List<ColoredDashboardItem>> getAllItems(int slotCount) {
    try {
      if (_localItems != null) {
        return _localItems![slotCount]!.values.toList();
      }

      return Future.microtask(() async {
        _preferences = await SharedPreferences.getInstance();

        var init = _preferences.getBool("init") ?? false;

        if (!init) {
          _localItems = {
            for (var s in _slotCounts)
              s: _default[s]!
                  .asMap()
                  .map((key, value) => MapEntry(value.identifier, value))
          };

          for (var s in _slotCounts) {
            await _preferences.setString(
                "layout_data_$s",
                json.encode(_default[s]!.asMap().map((key, value) =>
                    MapEntry(value.identifier, value.toMap()))));
          }

          await _preferences.setBool("init", true);
        }

        var js = json.decode(_preferences.getString("layout_data_$slotCount")!);

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

    await _preferences.setString("layout_data_$slotCount", js);
  }

  @override
  FutureOr<void> onItemsAdded(
      List<ColoredDashboardItem> items, int slotCount) async {
    for (var s in _slotCounts) {
      for (var i in items) {
        _localItems![s]?[i.identifier] = i;
      }

      await _preferences.setString(
          "layout_data_$s",
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
      }

      await _preferences.setString(
          "layout_data_$s",
          json.encode(_localItems![s]!
              .map((key, value) => MapEntry(key, value.toMap()))));
    }
  }

  Future<void> clear() async {
    for (var s in _slotCounts) {
      _localItems?[s]?.clear();
      await _preferences.remove("layout_data_$s");
    }
    _localItems = null;
    await _preferences.setBool("init", false);
  }

  @override
  bool get layoutsBySlotCount => true;

  @override
  bool get cacheItems => true;
}
