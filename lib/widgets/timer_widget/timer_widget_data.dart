import 'package:flutter/material.dart';

class TimerWidgetData {
  String name;
  Color? backgroundColor;
  int initialTime;
  bool countNegative;
  int currentTime;

  TimerWidgetData({
    required this.name,
    this.backgroundColor,
    required this.initialTime,
    required this.currentTime,
    this.countNegative = true,
  });

  TimerWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        backgroundColor = json['backgroundColor'] == null
            ? null
            : Color(json['backgroundColor']),
        initialTime = json['initialTime'],
        countNegative = json['countNegative'] == 1,
        currentTime = json['currentTime'] ?? json['initialTime'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'backgroundColor': backgroundColor?.value,
        'initialTime': initialTime,
        'countNegative': countNegative ? 1 : 0,
        'currentTime': currentTime,
      };
}
