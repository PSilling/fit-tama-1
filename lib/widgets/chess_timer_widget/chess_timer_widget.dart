import 'dart:async';
import 'dart:math';

import 'package:board_aid/util/themes.dart';
import 'package:board_aid/widgets/font_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import '../../views/edit_views/edit_chess_timer_widget_view.dart';
import '../editable.dart';
import 'chess_timer_widget_data.dart';

class ChessTimerWidget extends StatefulWidget {
  final ChessTimerWidgetData initData;
  final bool startEditing;

  const ChessTimerWidget(
      {super.key, required this.initData, required this.startEditing});

  @override
  State<StatefulWidget> createState() => ChessTimerWidgetState();
}

enum TimerWidgetTimerState { init, running, paused }

class ChessTimerWidgetState extends State<ChessTimerWidget>
    implements Editable<ChessTimerWidget> {

  late TimerWidgetTimerState _currentState;

  bool _isEditing = false;
  late ChessTimerWidgetData _data;

  ChessTimerWidgetData get data => _data;

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
    _currentState = TimerWidgetTimerState.init;
    super.initState();
  }

  void runTimer(int t) {
    setState(() {
      _countdownTimer = Timer(const Duration(seconds: 1), () {
        updateTimer(t);
      });
      _currentState = TimerWidgetTimerState.running;
    });
  }

  void run() {
    runTimer(_data.activeTimer);
  }

  void pause() {
    setState(() {
      if(_currentState == TimerWidgetTimerState.running){
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
      _data.currentTimes = List.from(_data.initialTimes);
      _data.activeTimer = 0;
    });
  }

  void updateTimer(int t) {
    setState(() {
      if (_currentState == TimerWidgetTimerState.running) {
        _countdownTimer = Timer(const Duration(seconds: 1), () {
          updateTimer(t);
        });
        _data.currentTimes[t]--;
        if (_data.currentTimes[t] == 0) { // notification (once)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "player's ${_data.activeTimer + 1} '${_data.name}' timer is up!",
                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        if (_data.currentTimes[t] <= 0) {
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

  String getPartString(String inp) =>
      inp.substring((inp.length / 1.25).round());

  TextStyle getStyle(int i) {
    var contentType = i == _data.activeTimer
        ? ThemeHelper.widgetContentMain(context)
        : ThemeHelper.widgetContentSecondary(context);

    return _data.currentTimes[i] <= 0
        ? contentType.copyWith(color: Theme.of(context).colorScheme.error)
        : contentType;
  }

  void _onTap() {
    if (_isEditing) {
      _openEditView();
      return;
    }
    switch (_currentState) {
      case TimerWidgetTimerState.init:
        runTimer(_data.activeTimer);
        break;
      case TimerWidgetTimerState.running:
        pause();
        _data.activeTimer = (_data.activeTimer + 1) % _data.currentTimes.length;
        runTimer(_data.activeTimer);
        break;
      case TimerWidgetTimerState.paused:
        if (_data.currentTimes.reduce(min) <= 0 && !_data.countNegative) {
          reset();
        } else {
          runTimer(_data.activeTimer);
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
        builder: (context) => EditChessTimerWidgetView(
          data: _data,
          setData: (data) {
            setState(() {
              _data = data;
              _data.currentTimes = List.from(_data.initialTimes);
              _currentState = TimerWidgetTimerState.init;
              _countdownTimer = null;
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
              Row(
                children: [
                  FontSpacer(
                    text: getPartString(
                        formatTime(_data.initialTimes.reduce(max).abs())),
                    style: ThemeHelper.widgetContentMain(context),
                  ),
                  for (int i = 0; i < data.currentTimes.length; i++) ...[
                    Transform.scale(
                      scale: i == _data.activeTimer ? 1.1 : 0.8,
                      child: Text(
                        formatTime(_data.currentTimes[i]),
                        style: getStyle(i),
                      ),
                    ),
                    if (i + 1 < _data.currentTimes.length)
                      FontSpacer(
                          text: getPartString(
                              formatTime(_data.initialTimes.reduce(max).abs())),
                          style: ThemeHelper.widgetContentMain(context)),
                  ],
                  FontSpacer(
                      text: getPartString(
                          formatTime(_data.initialTimes.reduce(max).abs())),
                      style: ThemeHelper.widgetContentMain(context)),
                ],
              ),
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
            if (_currentState == TimerWidgetTimerState.init &&
                !const ListEquality().equals(_data.currentTimes, _data.initialTimes))
              _themedIconButton(Icons.replay,
                  onPressed: reset,
                  context: context,
                  semanticLabel: "Reset the timer"),
            if (_currentState == TimerWidgetTimerState.running)
              _themedIconButton(
                Icons.pause,
                onPressed: pause,
                context: context,
                semanticLabel: "Pause the timer",
              ),
            if (_currentState == TimerWidgetTimerState.paused
                && _data.currentTimes.reduce(min) <= 0 && !_data.countNegative)
              _themedIconButton(Icons.replay,
                  onPressed: reset,
                  context: context,
                  semanticLabel: "Reset the timer"),
            if (_currentState == TimerWidgetTimerState.paused
                && !(_data.currentTimes.reduce(min) <= 0 && !_data.countNegative)) ...[
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

  @override
  void dispose(){
    if(_currentState != TimerWidgetTimerState.init){
      _countdownTimer?.cancel();
    }
    super.dispose();
  }

}
