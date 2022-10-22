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
    this.image = const AssetImage('assets/placeholder.png'),
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
}
