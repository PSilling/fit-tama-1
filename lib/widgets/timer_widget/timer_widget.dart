import 'dart:async';

import 'package:board_aid/util/themes.dart';
import 'package:board_aid/widgets/font_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../views/edit_views/edit_timer_widget_view.dart';
import '../editable.dart';
import 'timer_widget_data.dart';

class TimerWidget extends StatefulWidget {
  final TimerWidgetData initData;
  final bool startEditing;

  const TimerWidget(
      {super.key, required this.initData, required this.startEditing});

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
  late Timer? _countdownTimer;

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

  @override
  void dispose() {
    if (_currentState != TimerWidgetTimerState.init) {
      _countdownTimer?.cancel();
    }
    super.dispose();
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
      if (_currentState != TimerWidgetTimerState.init) {
        _currentState = TimerWidgetTimerState.paused;
        _countdownTimer!.cancel();
      }
    });
  }

  void reset() {
    setState(() {
      if(_currentState != TimerWidgetTimerState.init){
        _countdownTimer!.cancel();
      }
      _currentState = TimerWidgetTimerState.init;
      _currentTime = _data.initialTime;
    });
  }

  void update() {
    setState(() {
      if (_currentState == TimerWidgetTimerState.running) {
        _countdownTimer = Timer(const Duration(seconds: 1), update);
        _currentTime--;
        if (_currentTime == 0) { // notification (once)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "'${_data.name}' timer is up!",
                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        if (_currentTime <= 0) {
          if (_data.countNegative) {  // vibrate (ongoing)
            HapticFeedback.mediumImpact();
          } else { // vibrate more and stop
            HapticFeedback.vibrate();
            _currentState = TimerWidgetTimerState.paused;
          }
        }
      }
    });
  }

  String formatTime(int time) {
    if (!_data.countNegative && time < 0) return "0s";
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
      _openEditView();
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
        if (_currentTime <= 0 && !_data.countNegative) {
          reset();
        } else {
          run();
        }
        break;
    }
  }

  void _openEditView() {
    if(_currentState == TimerWidgetTimerState.running){
      _countdownTimer!.cancel();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTimerWidgetView(
          data: _data,
          setData: (data) {
            setState(() {
              _data = data;
              _currentTime = data.initialTime;
              _countdownTimer = null;
              _currentState = TimerWidgetTimerState.init;
            });
          },
        ),
      ),
    );
  }

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
                    ? ThemeHelper.widgetContentMain(context)
                        .copyWith(color: Theme.of(context).colorScheme.error)
                    : ThemeHelper.widgetContentMain(context),
              ),
              FontSpacer(
                  text: formatTime(-data.initialTime.abs()),
                  style: ThemeHelper.widgetContentMain(context)),
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
          iconSize: 1000,
          icon: Icon(icon,
              semanticLabel: semanticLabel,
              color: ThemeHelper.widgetTitleBottom(context).color),
        ),
      );

  Widget _buttonWidget(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: IgnorePointer(
        ignoring: _isEditing,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
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
            if (_currentState == TimerWidgetTimerState.paused
                && _currentTime <= 0 && !_data.countNegative)
              _themedIconButton(Icons.replay,
                  onPressed: reset,
                  context: context,
                  semanticLabel: "Reset the timer"),
            if (_currentState == TimerWidgetTimerState.paused
                && !(_currentTime <= 0 && !_data.countNegative)) ...[
              _themedIconButton(
                Icons.play_arrow,
                onPressed: run,
                context: context,
                semanticLabel: "Resume the timer",
              ),
              _themedIconButton(Icons.replay,
                  onPressed: reset,
                  context: context,
                  semanticLabel: "Reset the timer"),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            _data.backgroundColor ?? ThemeHelper.cardBackgroundColor(context),
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
      ),
    );
  }
}
