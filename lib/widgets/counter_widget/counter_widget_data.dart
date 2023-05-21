import 'dart:convert';

import 'package:flutter/material.dart';

class CounterWidgetData {
  String name;
  Color? backgroundColor;
  bool isUneven;
  List<int> scale;
  int defaultIndex;
  bool isLeftDeath;
  bool isRightDeath;
  int currentIndex;

  CounterWidgetData(
      {required this.name,
      this.backgroundColor,
      required this.isUneven,
      required this.scale,
      required this.defaultIndex,
      required this.isLeftDeath,
      required this.isRightDeath,
      required this.currentIndex});

  CounterWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        backgroundColor = json['backgroundColor'] == null
            ? null
            : Color(json['backgroundColor']),
        isUneven = json['isUneven'] == 1,
        scale = List<int>.from(jsonDecode(json['scale'])),
        defaultIndex = json['defaultIndex'],
        isLeftDeath = json['isLeftDeath'] == 1,
        isRightDeath = json['isRightDeath'] == 1,
        currentIndex = json['currentIndex'] ?? json['defaultIndex'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'backgroundColor': backgroundColor?.value,
        'isUneven': isUneven ? 1 : 0,
        'scale': jsonEncode(scale),
        'defaultIndex': defaultIndex,
        'isLeftDeath': isLeftDeath ? 1 : 0,
        'isRightDeath': isRightDeath ? 1 : 0,
        'currentIndex': currentIndex
      };
}
