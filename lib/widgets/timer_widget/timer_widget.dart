import 'dart:async';

import 'package:board_aid/themes.dart';
import 'package:flutter/material.dart';

import '../editable.dart';
import 'timer_edit_dialog.dart';
import 'timer_widget_data.dart';

class TimerWidget extends StatefulWidget {
  final TimerWidgetData initData;

  const TimerWidget({super.key, required this.initData});

  @override
  State<StatefulWidget> createState() => TimerWidgetState();
}

enum TimerWidgetTimerState { init, running, paused }

class TimerWidgetState extends State<TimerWidget>
    implements Editable<TimerWidget> {

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

  TimerWidgetData get data => _data;

  void run() {
    setState(() {
      _countdownTimer = Timer(const Duration(seconds: 1), update);
      _currentState = TimerWidgetTimerState.running;
    });
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
        _countdownTimer = Timer(const Duration(seconds: 1), update);
        _currentTime--;
      }
    });
  }

  String formatTime(int time) {
    var sign = time < 0 ? "-" : "";
    var seconds = time.abs() % 60;
    var minutes = time.abs() % 3600 ~/ 60;
    var hours = time.abs() ~/ 3600;

    if (hours == 0 && minutes == 0) {
      return "$sign${seconds}s";
    } else if (hours == 0) {
      return "$sign${minutes}m ${seconds}s";
    } else {
      return "$sign${hours}h ${minutes}m ${seconds}s";
    }
  }

  void _onTap() {
    if (_isEditing) {
      _showEditingDialog();
      return;
    }

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

  void _showEditingDialog() {
    showDialog(
      context: context,
      builder: (context) => TimerEditDialog(
        data: _data,
        setData: (data) {
          setState(() {
            _data = data;
            _currentTime = data.initialTime;
          });
        },
      ),
    );
  }

  Widget _titleWidget(BuildContext context) {
    return Text(
      _data.name,
      style: ThemeHelper.widgetTitle(context),
    );
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
                    style: _currentTime <= 0
                        ? ThemeHelper.widgetContentMain(context).copyWith(color: Colors.yellow)
                        : ThemeHelper.widgetContentMain(context),
                    formatTime(_currentTime),
                  ),
                ),
              )
            ]));
  }

  Widget _themedIcon(IconData? icon,
      {required BuildContext context, required String semanticLabel}) {
    final iconTheme = Theme.of(context).iconTheme;
    return Icon(
      icon,
      color: iconTheme.color,
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
                  icon: _themedIcon(Icons.play_arrow,
                      context: context, semanticLabel: "Start the timer"),
                ),
              if (_currentState == TimerWidgetTimerState.running)
                IconButton(
                  onPressed: pause,
                  icon: _themedIcon(Icons.pause,
                      context: context, semanticLabel: "Pause the timer"),
                ),
              if (_currentState == TimerWidgetTimerState.paused)
                IconButton(
                  onPressed: run,
                  icon: _themedIcon(Icons.play_arrow,
                      context: context, semanticLabel: "Resume the timer"),
                ),
              if (_currentState == TimerWidgetTimerState.paused)
                IconButton(
                  onPressed: reset,
                  icon: _themedIcon(Icons.replay,
                      context: context, semanticLabel: "Reset the timer"),
                ),
            ],
          )),
    );
  }

  @override
  void initState() {
    _data = widget.initData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: ThemeHelper.widgetBackgroundColor(context),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: const [BoxShadow()],
        ),
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
        ));
  }
}
