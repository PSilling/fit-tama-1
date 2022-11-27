import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class ColoredDashboardItem extends DashboardItem {
  ColoredDashboardItem(
      {this.color,
      required int width,
      required int height,
      required String identifier,
      required this.type,
      required this.data,
      int minWidth = 1,
      int minHeight = 1,
      int? maxHeight = 1,
      int? maxWidth = 2,
      int? startX,
      int? startY})
      : super(
            startX: startX,
            startY: startY,
            width: width,
            height: height,
            identifier: identifier,
            maxHeight: maxHeight,
            maxWidth: maxWidth,
            minWidth: minWidth,
            minHeight: minHeight);

  ColoredDashboardItem.fromMap(Map<String, dynamic> map)
      : color = map["color"] != null ? Color(map["color"]) : null,
        type = map['type'],
        data = map['data'],
        super.withLayout(map["item_id"], ItemLayout.fromMap(map["layout"]));

  Color? color;
  String type;
  String data;

  @override
  Map<String, dynamic> toMap() {
    var sup = super.toMap();
    if (color != null) {
      sup["color"] = color?.value;
    }
    sup['type'] = type;
    sup['data'] = data;

    return sup;
  }

  int getWidth() {
    return super.toMap()['layout']['w'];
  }
}
