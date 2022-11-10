import 'dart:math';

import 'package:flutter/material.dart';

/// Customisable preset of board game widgets.
class PresetModel {
  late final String id;
  String name;
  String game;
  int iconCode;
  bool isFavourite;
  int openedCount;
  Color backgroundColor;

  PresetModel({
    String? id,
    this.name = '',
    this.game = '',
    this.iconCode = 0xe046, // adb
    this.isFavourite = false,
    this.openedCount = 0,
    this.backgroundColor = Colors.blue,
  }) {
    if (id != null) {
      this.id = id;
    } else {
      this.id = Random().nextInt(1000).toString() +
          DateTime.now().microsecondsSinceEpoch.toString();
    }
  }

  /// Loads a preset from its JSON representation.
  PresetModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        game = json['game'],
        iconCode = json['iconCode'],
        isFavourite = json['isFavourite'],
        openedCount = json['openedCount'],
        backgroundColor = Color(json['backgroundColor']);

  /// Generates a JSON representation of the preset.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'game': game,
        'iconCode': iconCode,
        'isFavourite': isFavourite,
        'openedCount': openedCount,
        'backgroundColor': backgroundColor.value,
      };

  /// Creates a deep copy of the preset.
  PresetModel copy() => PresetModel(
        id: id,
        name: name,
        game: game,
        iconCode: iconCode,
        isFavourite: isFavourite,
        openedCount: openedCount,
        backgroundColor: backgroundColor,
      );
}
