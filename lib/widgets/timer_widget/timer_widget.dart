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
  late Timer _countdownTimer;

  @override
  bool get isEditing => _isEditing;

  @override
  set isEditing(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }

  void run() {
    setState(() {
      _currentState = TimerWidgetTimerState.running;
    });
    _countdownTimer = Timer(const Duration(seconds: 1), update);
  }

  void pause() {
    setState(() {
      _currentState = TimerWidgetTimerState.paused;
      _countdownTimer.cancel();
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
        _countdownTimer = Timer(const Duration(seconds: 1), update);
      }
    });
  }

  void _onTap() { // TODO: Re-add.
    switch (_currentState) {
      case TimerWidgetTimerState.init:
        run();
        break;
      case TimerWidgetTimerState.running:
        pause();
        break;
      case TimerWidgetTimerState.paused:
        run();
        break;
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
                  child: Text(
                    style: _currentTime <= 0 ?
                      const TextStyle(color: Colors.red) : const TextStyle(),
                    "${_currentTime}s",
                  ),
                ),
              )
            ]
        )
    );
  }

  Widget _themedIcon(IconData? icon, {required BuildContext context, required String semanticLabel}) {
    final iconTheme = Theme.of(context).iconTheme;
    final textTheme = Theme.of(context).textTheme;
    return Icon(
      icon,
      color: textTheme.displayLarge?.color,
      shadows: iconTheme.shadows,
      size: iconTheme.size,
      semanticLabel: semanticLabel,
    );
  }

  Widget _buttonWidget(BuildContext context) {
    return Center(
      child: IgnorePointer(
        ignoring: _isEditing,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_currentState == TimerWidgetTimerState.init)
              IconButton(
                onPressed: run,
                icon: _themedIcon(
                    Icons.play_arrow,
                    context: context,
                    semanticLabel: "Start the timer"
                ),
              ),
            if (_currentState == TimerWidgetTimerState.running)
              IconButton(
                onPressed: pause,
                icon: _themedIcon(
                    Icons.pause,
                    context: context,
                    semanticLabel: "Pause the timer"
                ),
              ),
            if (_currentState == TimerWidgetTimerState.paused)
              IconButton(
                onPressed: run,
                icon: _themedIcon(
                    Icons.play_arrow,
                    context: context,
                    semanticLabel: "Resume the timer"
                ),
              ),
            if (_currentState == TimerWidgetTimerState.paused)
              IconButton(
                onPressed: reset,
                icon: _themedIcon(
                    Icons.replay,
                    context: context,
                    semanticLabel: "Reset the timer"
                ),
              ),
          ],
        )
      ),
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
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _titleWidget(context),
            Expanded(
              child: _timeWidget(context),
            ),
            _buttonWidget(context)
          ],
        ),
      )
    );
  }

}
