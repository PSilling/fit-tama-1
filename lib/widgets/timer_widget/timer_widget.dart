import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tabletop_assistant/widgets/editable.dart';

import 'timer_widget_data.dart';

class TimerWidget extends StatefulWidget {
  final TimerWidgetData initData;

  const TimerWidget({super.key, required this.initData});

  @override
  State<StatefulWidget> createState() => TimerWidgetState();
}

enum TimerWidgetTimerState {
  init, running, paused
}

class TimerWidgetState extends State<TimerWidget>
    implements Editable<TimerWidget> {
  static const decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow()],
  );

  late int _currentTime = _data.initialTime;
  TimerWidgetTimerState _currentState = TimerWidgetTimerState.init;
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
    setState(() {
      _currentState = TimerWidgetTimerState.running;
    });
    update();
  }

  void pause() {
    setState(() {
      _currentState = TimerWidgetTimerState.paused;
    });
  }

  void reset() {
    setState(() {
      _currentState = TimerWidgetTimerState.init;
      _currentTime = _data.initialTime;
    });
  }

  void update() {
    setState(() {
      if (_currentState == TimerWidgetTimerState.running) {
        _currentTime--;
        Timer(const Duration(seconds: 1), update);
      }
    });
  }

  void _onTap() {
    switch (_currentState) {
      case TimerWidgetTimerState.init:
        start();
        break;
      case TimerWidgetTimerState.running:
        pause();
        break;
      case TimerWidgetTimerState.paused:
        throw StateError("_onTap called when widget is paused.");
    }
  }

  Widget _titleWidget(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Text(_data.name, style: theme.headlineLarge);
  }

  Widget _timeWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text( // TODO: Effect on value <= 0.
                    "${_currentTime}s",
                  ),
                ),
              )
            ]
        )
    );
  }

  // TODO: Editing dialog.

  @override
  void initState() {
    _data = widget.initData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      height: 240,
      width: 240,
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [ // TODO: Add buttons (based on state) and remove _onTap.
            _titleWidget(context),
            Expanded(
              child: _timeWidget(context),
            )
          ],
        ),
      ),
    );
  }

}
