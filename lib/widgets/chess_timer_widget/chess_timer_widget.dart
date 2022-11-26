import 'dart:async';
import 'dart:math';

import 'package:board_aid/util/themes.dart';
import 'package:board_aid/widgets/font_spacer.dart';
import 'package:flutter/material.dart';

import '../editable.dart';
import 'chess_timer_widget_data.dart';
import 'chess_timer_edit_dialog.dart';

class ChessTimerWidget extends StatefulWidget {
  final ChessTimerWidgetData initData;
  final bool startEditing;

  const ChessTimerWidget({super.key,
    required this.initData, required this.startEditing});

  @override
  State<StatefulWidget> createState() => ChessTimerWidgetState();
}

enum TimerWidgetTimerState { init, running, paused }

class ChessTimerWidgetState extends State<ChessTimerWidget> implements Editable<ChessTimerWidget> {

  late int _numTimers;
  int _activeTimer = 0;

  late List<int> _currentTimes = List.from(_data.initialTimes);
  late List<TimerWidgetTimerState> _currentStates;

  bool _isEditing = false;
  late ChessTimerWidgetData _data;
  ChessTimerWidgetData get data => _data;

  late List<Timer?> _countdownTimers;

  @override
  bool get isEditing => _isEditing;

  @override
  set isEditing(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }
  
  bool get allInit => _currentStates
      .fold(true, (prev, elem) => prev && elem == TimerWidgetTimerState.init);
  bool get anyRunning => _currentStates
      .fold(false, (prev, elem) => prev || elem == TimerWidgetTimerState.running);
  bool get allPausedOrInit => _currentStates
      .fold(true, (prev, elem) => prev &&
        [TimerWidgetTimerState.paused, TimerWidgetTimerState.init].contains(elem))
      && ! allInit;

  @override
  void initState() {
    _numTimers = widget.initData.initialTimes.length;
    _isEditing = widget.startEditing;
    _data = widget.initData;
    _currentStates = List<TimerWidgetTimerState>
        .generate(_numTimers, (index) => TimerWidgetTimerState.init);
    _countdownTimers = List<Timer?>.generate(_numTimers, (index) => null);
    super.initState();
  }

  void runTimer(int t) {
    setState(() {
      _countdownTimers[t] = Timer(const Duration(seconds: 1), () {updateTimer(t);});
      _currentStates[t] = TimerWidgetTimerState.running;
    });
  }

  void run(){
    runTimer(_activeTimer);
  }

  void pauseTimer(int t) {
    setState(() {
      _currentStates[t] = TimerWidgetTimerState.paused;
      _countdownTimers[t]?.cancel();
    });
  }

  void pause(){
    pauseTimer(_activeTimer);
  }

  void reset() {
    setState(() {
      _currentStates = List<TimerWidgetTimerState>
          .generate(_currentStates.length, (index) => TimerWidgetTimerState.init);
      _currentTimes = List.from(_data.initialTimes);
    });
  }

  void updateTimer(int t) {
    setState(() {
      if (_currentStates[t] == TimerWidgetTimerState.running) {
        _countdownTimers[t] = Timer(const Duration(seconds: 1), () {updateTimer(t);});
        _currentTimes[t]--;
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

  String getPartString(String inp) => inp.substring((inp.length/1.25).round());

  TextStyle getStyle(int i){

    var contentType = i == _activeTimer
      ? ThemeHelper.widgetContentMain(context)
      : ThemeHelper.widgetContentSecondary(context);

    return _currentTimes[i] <= 0
        ? contentType.copyWith(color: Theme.of(context).colorScheme.error)
        : contentType;
  }

  void _onTap(){
    if (_isEditing) {
      _showEditingDialog();
      return;
    }
    switch (_currentStates[_activeTimer]) {
      case TimerWidgetTimerState.init:
        runTimer(_activeTimer);
        break;
      case TimerWidgetTimerState.running:
        pauseTimer(_activeTimer);
        _activeTimer = (_activeTimer + 1) % _currentTimes.length;
        runTimer(_activeTimer);
        break;
      case TimerWidgetTimerState.paused:
        runTimer(_activeTimer);
        break;
    }
  }

  void _showEditingDialog() {
    showDialog(
      context: context,
      builder: (context) => ChessTimerEditDialog(
        data: _data,
        setData: (data) {
          setState(() {
            _data = data;
            _currentTimes = List.from(data.initialTimes);
            _numTimers = data.initialTimes.length;
            _currentStates = List<TimerWidgetTimerState>
                .generate(_numTimers, (index) => TimerWidgetTimerState.init);
            _countdownTimers = List<Timer?>.generate(_numTimers, (index) => null);
          });
        },
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
                      text: getPartString(formatTime(-data.initialTimes.reduce(max).abs())),
                      style: ThemeHelper.widgetContentMain(context),
                  ),
                  for (int i = 0; i < _numTimers; i++) ...[
                    Transform.scale(
                      scale: i == _activeTimer ? 1.1 : 0.8,
                      child: Text(
                        formatTime(_currentTimes[i]),
                        style: getStyle(i),
                      ),
                    ),
                    if (i+1 < _numTimers)
                      FontSpacer(
                        text: getPartString(formatTime(-data.initialTimes.reduce(max).abs())),
                        style: ThemeHelper.widgetContentMain(context)
                      ),
                  ],
                  FontSpacer(
                      text: getPartString(formatTime(-data.initialTimes.reduce(max).abs())),
                      style: ThemeHelper.widgetContentMain(context)
                  ),
                ]
              )
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
            if (allInit)
              _themedIconButton(
                Icons.play_arrow,
                onPressed: run,
                context: context,
                semanticLabel: "Start the timer",
              ),
            if (anyRunning)
              _themedIconButton(
                Icons.pause,
                onPressed: pause,
                context: context,
                semanticLabel: "Pause the timer",
              ),
            if (allPausedOrInit) ...[
              _themedIconButton(
                Icons.play_arrow,
                onPressed: run,
                context: context,
                semanticLabel: "Resume the timer",
              ),
              _themedIconButton(
                Icons.replay,
                onPressed: reset,
                context: context,
                semanticLabel: "Reset the timer"
               ),
            ],
          ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeHelper.cardBackgroundColor(context),
        borderRadius:
        BorderRadius.all(Radius.circular(ThemeHelper.borderRadius())),
        boxShadow: const [BoxShadow()],
      ),
      padding: ThemeHelper.cardPadding(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTap,
        child:  Column(
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
      )
    );
  }
}
