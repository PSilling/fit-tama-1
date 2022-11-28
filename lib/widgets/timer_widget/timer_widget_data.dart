import 'package:flutter/material.dart';

class TimerWidgetData {
  String name;
  Color? backgroundColor;
  int initialTime;

  TimerWidgetData({
    required this.name,
    this.backgroundColor,
    required this.initialTime,
  });

  TimerWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        backgroundColor = json['backgroundColor'] == null
            ? null
            : Color(json['backgroundColor']),
        initialTime = json['initialTime'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'backgroundColor': backgroundColor?.value,
        'initialTime': initialTime,
      };
}
