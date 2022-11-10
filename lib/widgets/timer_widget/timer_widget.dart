import 'dart:async';

import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

import '../editable.dart';
import 'timer_edit_dialog.dart';
import 'timer_widget_data.dart';

class TimerWidget extends StatefulWidget {
  final TimerWidgetData initData;
  final bool startEditing;

  const TimerWidget({super.key,
    required this.initData, required this.startEditing});

  @override
  State<StatefulWidget> createState() => TimerWidgetState();
}

enum TimerWidgetTimerState { init, running, paused }

class TimerWidgetState extends State<TimerWidget> implements Editable<TimerWidget> {
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

  @override
  void initState() {
    _isEditing = widget.startEditing;
    _data = widget.initData;
    super.initState();
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

  // Has size of widest displayed number, to keep the number positioning/size even
  Widget _sizer({required TextStyle? style}) => Text(
      formatTime(-data.initialTime.abs()),
      style: style?.copyWith(color: Colors.transparent)
    );

  Widget _titleWidget(BuildContext context) => FittedBox(
      fit: BoxFit.contain,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 1, minWidth: 1),
        child: Text(
          _data.name,
          style: ThemeHelper.widgetTitle(context),
        ),
      ),
    );

  Widget _timeWidget(BuildContext context) {
    return Padding(
      padding: ThemeHelper.cardPadding(),
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                formatTime(_currentTime),
                style: _currentTime <= 0
                    ? ThemeHelper.widgetContentMain(context).copyWith(color: Colors.yellow)
                    : ThemeHelper.widgetContentMain(context),
              ),
              _sizer(style: ThemeHelper.widgetContentMain(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themedIconButton(IconData? icon,
          {required BuildContext context,
          void Function()? onPressed,
          required String semanticLabel}) =>
      FittedBox(
        fit: BoxFit.contain,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon,
              semanticLabel: semanticLabel,
              color: ThemeHelper.widgetTitleBottom(context).color),
        ),
      );

  Widget _buttonWidget(BuildContext context) {
    return IgnorePointer(
      ignoring: _isEditing,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_currentState == TimerWidgetTimerState.init)
            _themedIconButton(
              Icons.play_arrow,
              onPressed: run,
              context: context,
              semanticLabel: "Start the timer",
            ),
          if (_currentState == TimerWidgetTimerState.running)
            _themedIconButton(
              Icons.pause,
              onPressed: pause,
              context: context,
              semanticLabel: "Pause the timer",
            ),
          if (_currentState == TimerWidgetTimerState.paused)
            _themedIconButton(
              Icons.play_arrow,
              onPressed: run,
              context: context,
              semanticLabel: "Resume the timer",
            ),
          if (_currentState == TimerWidgetTimerState.paused)
            _themedIconButton(Icons.replay,
                onPressed: reset,
                context: context,
                semanticLabel: "Reset the timer"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: ThemeHelper.widgetBackgroundColor(context),
          borderRadius:
              BorderRadius.all(Radius.circular(ThemeHelper.borderRadius())),
          boxShadow: const [BoxShadow()],
        ),
        padding: ThemeHelper.cardPadding(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: _titleWidget(context),
              ),
              Expanded(
                flex: 3,
                child: _timeWidget(context),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: _buttonWidget(context),
              ),
            ],
          ),
        ));
  }
}
