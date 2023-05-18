import 'dart:async';
import 'dart:convert';

import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/chess_timer_widget/chess_timer_widget.dart';
import '../../widgets/chess_timer_widget/chess_timer_widget_data.dart';
import '../../widgets/counter_widget/counter_widget.dart';
import '../../widgets/counter_widget/counter_widget_data.dart';
import '../../widgets/dice_widget/dice_widget.dart';
import '../../widgets/dice_widget/dice_widget_data.dart';
import '../../widgets/timer_widget/timer_widget.dart';
import '../../widgets/timer_widget/timer_widget_data.dart';
import 'colored_dashboard_item.dart';

class PresetWidgetsStorage
    extends DashboardItemStorageDelegate<ColoredDashboardItem> {
  PresetWidgetsStorage(this.presetLink, this.startEdit);

  String presetLink;
  bool startEdit;
  late SharedPreferences _preferences;
  final List<int> _slotCounts = [2];
  Map<int, Map<String, ColoredDashboardItem>>? _localItems;
  Map<String, dynamic>? widgets;
  bool? _editing;

  final Map<String, Widget Function(String i, bool e, int w)> _widgetMap = {
    'counter': (l, e, w) => CounterWidget(
          key: GlobalKey(),
          initData: CounterWidgetData.fromJson(jsonDecode(l)),
          startEditing: e,
          width: w,
        ),
    'dice': (l, e, w) => DiceWidget(
          key: GlobalKey(),
          initData: DiceWidgetData.fromJson(jsonDecode(l)),
          startEditing: e,
        ),
    'timer': (l, e, w) => TimerWidget(
          key: GlobalKey(),
          initData: TimerWidgetData.fromJson(jsonDecode(l)),
          startEditing: e,
        ),
    'chess_timer': (l, e, w) => ChessTimerWidget(
          key: GlobalKey(),
          initData: ChessTimerWidgetData.fromJson(jsonDecode(l)),
          startEditing: e,
        )
  };

  final Map<String, String> defaultData = {
    'counter': jsonEncode(CounterWidgetData(
        name: "Counter",
        isUneven: false,
        scale: List<int>.generate(10, (i) => i + 1),
        defaultIndex: 4,
        currentIndex: ValueNotifier<int>(4),
        isLeftDeath: false,
        isRightDeath: false)),
    'dice': jsonEncode(
        DiceWidgetData(name: 'Dice', numberOfDice: 2, numberOfSides: 6)),
    'timer': jsonEncode(TimerWidgetData(name: 'Timer', initialTime: 30, currentTime: 30)),
    'chess_timer': jsonEncode(
        ChessTimerWidgetData(name: 'Chess timer', initialTimes: [90, 90], currentTimes: [90, 90])),
  };

  late final Map<int, List<ColoredDashboardItem>> _default = {
    2: <ColoredDashboardItem>[],
  };

  dynamic buildWidget(ColoredDashboardItem item) {
    _editing ??= startEdit;
    return _widgetMap[item.type]!(item.data, _editing!, item.getWidth());
  }

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

        var js = json.decode(
            _preferences.getString("preset_data_${presetLink}_$slotCount")!);

        _localItems = {
          slotCount: {
            for (var e in js!.values
                .map((value) => ColoredDashboardItem.fromMap(value))
                .toList())
              e.identifier: e
          }
        };

        widgets = {
          for (var e in _localItems![slotCount]!.keys)
            e: buildWidget(_localItems![slotCount]![e]!)
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

    for (var id in widgets!.keys) {
      if (widgets![id].key.currentState == null) {
        return;
      }
      _localItems?[slotCount]?[id]?.data =
          jsonEncode(widgets![id].key.currentState.data);
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
        widgets![i.identifier] = buildWidget(i);
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

  void setWidgetsEditing(value) {
    _editing = value;
    for (var item in widgets!.values) {
      if (item != null) {
        item.key.currentState.isEditing = _editing;
      }
    }
  }

  void resetAll(){
    for (var item in widgets!.values){
      if(item != null){
        if (item! is CounterWidget){
          item.key.currentState.resetIndex();
        }
        if (item! is TimerWidget || item! is ChessTimerWidget){
          item.key.currentState.reset();
        }
      }
    }
  }

  @override
  bool get layoutsBySlotCount => true;

  @override
  bool get cacheItems => true;
}
