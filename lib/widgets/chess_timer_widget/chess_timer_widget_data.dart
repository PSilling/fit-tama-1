import 'dart:convert';

import 'package:flutter/material.dart';

class ChessTimerWidgetData {
  String name;
  Color? backgroundColor;
  List<int> initialTimes;
  bool countNegative;

  bool get isTogether =>
      initialTimes.fold(true, (prev, elem) => prev && elem == initialTimes[0]);

  bool get isSeparate => !isTogether;

  ChessTimerWidgetData({
    required this.name,
    this.backgroundColor,
    required this.initialTimes,
    this.countNegative = true,
  });

  ChessTimerWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        backgroundColor = json['backgroundColor'] == null
            ? null
            : Color(json['backgroundColor']),
        initialTimes = List<int>.from(jsonDecode(json['initialTime'])),
        countNegative = json['countNegative'] == 1;

  Map<String, dynamic> toJson() => {
        'name': name,
        'backgroundColor': backgroundColor?.value,
        'initialTime': jsonEncode(initialTimes),
        'countNegative': countNegative ? 1 : 0,
      };
}
