import 'dart:convert';

import 'package:flutter/material.dart';

class ChessTimerWidgetData {
  String name;
  Color? backgroundColor;
  List<int> initialTimes;
  bool countNegative;
  List<int> currentTimes;
  int activeTimer;

  bool get isTogether =>
      initialTimes.fold(true, (prev, elem) => prev && elem == initialTimes[0]);

  bool get isSeparate => !isTogether;

  ChessTimerWidgetData({
    required this.name,
    this.backgroundColor,
    required this.initialTimes,
    required this.currentTimes,
    this.countNegative = true,
    this.activeTimer = 0,
  });

  ChessTimerWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        backgroundColor = json['backgroundColor'] == null
            ? null
            : Color(json['backgroundColor']),
        initialTimes = List<int>.from(jsonDecode(json['initialTime'])),
        countNegative = json['countNegative'] == 1,
        currentTimes = json['currentTimes'] == null
          ? List<int>.from(jsonDecode(json['initialTimes']))
          : List<int>.from(jsonDecode(json['currentTimes'])),
        activeTimer = json['activeTimer'] ?? 0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'backgroundColor': backgroundColor?.value,
        'initialTime': jsonEncode(initialTimes),
        'countNegative': countNegative ? 1 : 0,
        'currentTimes': jsonEncode(currentTimes),
        'activeTimer': activeTimer,
      };
}
