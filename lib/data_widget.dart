import 'package:auto_size_text/auto_size_text.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      initData: CounterWidgetData(
        name: "Round",
        isUneven: false,
        scale: [1, 2, 3],
        defaultIndex: 2,
        isLeftDeath: false,
        isRightDeath: false
      )
    ),
    "dice": (l) => DiceWidget(
      initData: DiceWidgetData(
        name: 'Dice',
        numberOfDice: 2,
        numberOfSides: 2
      )
    ),
    "timer": (l) => TimerWidget(
      initData: TimerWidgetData(
        name: 'Timer',
        initialTime: 90
      )
    ),
  };

  @override
  Widget build(BuildContext context) {
    return _map[item.data]!(item);
  }
}
