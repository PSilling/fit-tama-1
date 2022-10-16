import 'package:flutter/material.dart';
import 'package:tabletop_assistant/widgets/editable.dart';

import 'timer_widget_data.dart';

class TimerWidget extends StatefulWidget {
  final TimerWidgetData initData;

  const TimerWidget({super.key, required this.initData});

  @override
  State<StatefulWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget>
    implements Editable<TimerWidget> {
  static const decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow()],
  );

  // TODO: Current time.
  // TODO: Current state (init, running, paused).
  bool _isEditing = false;
  late TimerWidgetData _data;

  @override
  bool get isEditing => _isEditing;

  @override
  set isEditing(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }

  void start() {
    // TODO: Start the timer.
    throw UnimplementedError();
  }

  void pause() {
    // TODO: Pause the timer.
    throw UnimplementedError();
  }

  void reset() {
    // TODO: Reset the timer to default value.
    throw UnimplementedError();
  }

  // TODO: Method for updating each second when running?

  // TODO: Editing dialog.

  @override
  void initState() {
    _data = widget.initData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
