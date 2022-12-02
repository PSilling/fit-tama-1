import 'package:flutter/material.dart';

class TimerWidgetData {
  String name;
  Color? backgroundColor;
  int initialTime;
  bool countNegative;

  TimerWidgetData({
    required this.name,
    this.backgroundColor,
    required this.initialTime,
    this.countNegative = true,
  });

  TimerWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        backgroundColor = json['backgroundColor'] == null
            ? null
            : Color(json['backgroundColor']),
        initialTime = json['initialTime'],
        countNegative = json['countNegative'] == 1;

  Map<String, dynamic> toJson() => {
        'name': name,
        'backgroundColor': backgroundColor?.value,
        'initialTime': initialTime,
        'countNegative': countNegative ? 1 : 0,
      };
}
