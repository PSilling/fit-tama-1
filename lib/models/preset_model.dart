import 'dart:math';

import 'package:flutter/material.dart';

/// Customisable preset of board game widgets.
class PresetModel {
  late final String id;
  String name;
  String game;
  AssetImage image;
  bool isFavourite;
  int openedCount;
  Color backgroundColor;

  PresetModel({
    String? id,
    this.name = '',
    this.game = '',
    this.image = const AssetImage('assets/placeholder.png'),   //TODO - remove placeholder image
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

  PresetModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      game = json['game'],
      image = const AssetImage('assets/placeholder.png'), //TODO - remove placeholder image
      isFavourite = json['isFavourite'],
      openedCount = json['openedCount'],
      backgroundColor = Color(json['backgroundColor']);

  Map<String, dynamic> toJson() => {    //TODO - add saving image
    'id': id,
    'name': name,
    'game': game,
    'isFavourite': isFavourite,
    'openedCount': openedCount,
    'backgroundColor': backgroundColor.value
  };
}
