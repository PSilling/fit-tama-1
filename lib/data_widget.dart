import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import './storage.dart';

import './widgets/counter_widget/counter_widget.dart';
import './widgets/counter_widget/counter_widget_data.dart';
import './widgets/dice_widget/dice_widget.dart';
import './widgets/dice_widget/dice_widget_data.dart';
import './widgets/timer_widget/timer_widget.dart';
import './widgets/timer_widget/timer_widget_data.dart';

const Color blue = Color(0xFF4285F4);
const Color red = Color(0xFFEA4335);
const Color yellow = Color(0xFFFBBC05);
const Color green = Color(0xFF34A853);

class DataWidget extends StatelessWidget {
  DataWidget({Key? key, required this.item}) : super(key: key);

  final ColoredDashboardItem item;

  final Map<String, Widget Function(ColoredDashboardItem i)> _map = {
    "counter": (l) => CounterWidget(
      initData: CounterWidgetData.fromJson(jsonDecode(l.data!))
    ),
    "dice": (l) => DiceWidget(
      initData: DiceWidgetData.fromJson(jsonDecode(l.data!))
    ),
    "timer": (l) => TimerWidget(
      initData: TimerWidgetData.fromJson(jsonDecode(l.data!))
    ),
  };

  @override
  Widget build(BuildContext context) {
    if (item.data != null){
      return _map[item.type]!(item);
    }
    //TODO - remove placeholder widget
    var layout = item.layoutData;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Text(
            "Subject to change \n ID: ${item.identifier}\n${[
              "x: ${layout.startX}",
              "y: ${layout.startY}",
              "w: ${layout.width}",
              "h: ${layout.height}",
              if (layout.minWidth != 1) "minW: ${layout.minWidth}",
              if (layout.minHeight != 1)
                "minH: ${layout.minHeight}",
              if (layout.maxWidth != null)
                "maxW: ${layout.maxWidth}",
              if (layout.maxHeight != null)
                "maxH : ${layout.maxHeight}"
            ].join("\n")}",
            style: const TextStyle(color: Colors.white),
          )),
    );

  }
}
