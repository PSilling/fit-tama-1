import 'package:flutter/material.dart';

class DiceWidgetData {
  String name;
  Color? backgroundColor;
  int numberOfDice;
  int numberOfSides;
  bool longPressToReroll;

  DiceWidgetData({
    this.name = "",
    this.backgroundColor,
    required this.numberOfDice,
    required this.numberOfSides,
    this.longPressToReroll = false,
  });

  DiceWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        backgroundColor = json['backgroundColor'] == null
            ? null
            : Color(json['backgroundColor']),
        numberOfDice = json['numberOfDice'],
        numberOfSides = json['numberOfSides'],
        longPressToReroll = json['longPressToReroll'] == 1;

  Map<String, dynamic> toJson() => {
        'name': name,
        'backgroundColor': backgroundColor?.value,
        'numberOfDice': numberOfDice,
        'numberOfSides': numberOfSides,
        'longPressToReroll': longPressToReroll ? 1 : 0
      };
}
