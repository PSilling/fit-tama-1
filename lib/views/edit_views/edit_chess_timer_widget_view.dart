import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/themes.dart';
import '../../widgets/chess_timer_widget/chess_timer_widget.dart';
import '../../widgets/chess_timer_widget/chess_timer_widget_data.dart';
import '../../widgets/dialog_select_input.dart';

class EditChessTimerWidgetView extends StatefulWidget {
  final ChessTimerWidgetData data;
  final void Function(ChessTimerWidgetData) setData;

  const EditChessTimerWidgetView({
    super.key,
    required this.data,
    required this.setData,
  });

  @override
  State<StatefulWidget> createState() => EditChessTimerWidgetViewState();
}

class EditChessTimerWidgetViewState extends State<EditChessTimerWidgetView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ChessTimerWidgetState> _previewKey = GlobalKey<ChessTimerWidgetState>();

  final List<int> _numTimersPossible = [2, 3];
  late _SeparateTimesSet _separateTimeSet;
  late List<int> _outputs;
  late int _outputLength;

  late List<FormBuilderTextField> timeInputFields;

  @override
  void initState() {
    _separateTimeSet =
        _SeparateTimesSet.fromData(isSeparate: widget.data.isSeparate);
    _outputs = List.from(widget.data.initialTimes);
    for (int i = 0;
        i <= _numTimersPossible.reduce(max) - _outputs.length;
        i++) {
      _outputs.add(_outputs[0]);
    }
    _outputLength = widget.data.initialTimes.length;

    super.initState();
  }

  /// Handles navigator pop and dice widget data saving on back button press.
  Future<bool> _onWillPop() {
    _validateAndSave();
    return Future.value(true);
  }

  /// Validates form inputs and saves if possible.
  void _validateAndSave() {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }
    if (formState.validate()) {
      formState.save();
      if (_separateTimeSet == _SeparateTimesSet.together) {
        widget.data.initialTimes =
            List.generate(_outputLength, (index) => _outputs[0]);
      } else {
        widget.data.initialTimes = List.generate(_outputLength, (index) => 0);
        for (var i = 0; i < _outputLength; i++) {
          widget.data.initialTimes[i] = _outputs[i];
        }
      }
      widget.setData(widget.data);
      _previewKey.currentState?.reset();
    }
  }

  void _onEditComplete(){
    _validateAndSave();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {});
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

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => WillPopScope(
            onWillPop: _onWillPop,
            child: Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              color: ThemeHelper.dialogBackground(context),
              child: SafeArea(
                top: false,
                child: child,
              ),
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewWidth =
        MediaQuery.of(context).size.width - 2 * ThemeHelper.cardSpacing();
    final previewHeight = previewWidth / 2;
    final iconSize = (Theme.of(context).iconTheme.size ?? 24) *
        ThemeHelper.largeIconSizeModifier;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: ThemeHelper.editViewBackground(context),
        appBar: AppBar(
          title: const Text('Customize Widget'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: ThemeHelper.editViewPadding(),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: ThemeHelper.subtitleFontSize,
                        color: ThemeHelper.editViewForeground(context),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: previewWidth,
                      height: previewHeight,
                      child: ChessTimerWidget(
                          key: _previewKey,
                          initData: widget.data,
                          startEditing: false
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Divider(
                      color: ThemeHelper.editViewForeground(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: ThemeHelper.subtitleFontSize,
                        color: ThemeHelper.editViewForeground(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderTextField(
                      style: TextStyle(
                        color: ThemeHelper.dialogForeground(context),
                      ),
                      cursorColor: ThemeHelper.dialogForeground(context),
                      name: "name",
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Title"),
                      textInputAction: TextInputAction.done,
                      initialValue: widget.data.name,
                      onSaved: (value) => widget.data.name = value ?? "",
                      onEditingComplete: _onEditComplete,
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: DialogSelectInput(
                      value: widget.data.backgroundColor,
                      defaultValue: ThemeHelper.cardBackgroundColor(context),
                      onSelected: (color) => setState(() {
                        widget.data.backgroundColor = color;
                      }),
                      itemLabelMap: ThemeHelper.cardBackgroundColors,
                      itemBuilder: (item) => Icon(
                        Icons.circle,
                        color: item,
                        size: iconSize * 1.8, // larger for easier selection
                      ),
                      label: 'Color',
                      dialogTitle: 'Pick a Color',
                      iconCode: Icons.circle.codePoint,
                      iconColor: widget.data.backgroundColor ??
                          ThemeHelper.cardBackgroundColor(context),
                      iconSize: iconSize,
                      heightDivisor: 3.0,
                      itemsPerRow: 4,
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderRadioGroup<String>(
                      activeColor: ThemeHelper.dialogForeground(context),
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Number of timers"),
                      name: "num_timers",
                      initialValue: _outputLength.toString(),
                      onChanged: (val) {
                        _outputLength = int.parse(val!);
                        _validateAndSave();
                        setState(() {});
                      },
                      options: List<FormBuilderFieldOption<String>>.generate(
                        _numTimersPossible.length,
                        (i) {
                          return FormBuilderFieldOption<String>(
                            value: _numTimersPossible[i].toString(),
                            child: Text(
                              _numTimersPossible[i].toString(),
                              style: TextStyle(
                                color: ThemeHelper.dialogForeground(context),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderRadioGroup<String>(
                      activeColor: ThemeHelper.dialogForeground(context),
                      decoration: ThemeHelper.dialogInputDecoration(
                        context,
                        label: "Timer ranges:",
                      ),
                      name: "timer_ranges",
                      initialValue: _separateTimeSet.label,
                      onChanged: (value) {
                        if (value != null) {
                          _separateTimeSet =
                              _SeparateTimesSet.fromStr(inputStr: value);
                          _validateAndSave();
                          setState(() {});
                        }
                      },
                      // onSaved: (value) => widget.data.isUneven = _EvennessOptions.isUneven(value: value),
                      options: [
                        _SeparateTimesSet.together.getOption(context),
                        _SeparateTimesSet.separate.getOption(context),
                      ],
                    ),
                  ),
                  for (var i = 0; i < _numTimersPossible.reduce(max); i++)
                    Visibility(
                      visible: i < 1 ||
                          (_separateTimeSet == _SeparateTimesSet.separate &&
                              i < _outputLength),
                      child: Padding(
                        padding: ThemeHelper.formPadding(),
                        child: GestureDetector(
                          onTap: () => _showDialog(
                            CupertinoTimerPicker(
                              initialTimerDuration: Duration(seconds: widget.data.initialTimes[i]),
                              onTimerDurationChanged: (value) {
                                _outputs[i] = value.inSeconds;
                              },
                            ),
                          ),
                          child: FormBuilderField(
                            name: 'init_time',
                            builder: (FormFieldState field) => InputDecorator(
                              decoration: ThemeHelper.dialogInputDecoration(context,
                                errorText: field.errorText,
                                hasBorder: true,
                                isDense: false,
                                hasPadding: true),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Initial time of player ${i+1}:'),
                                  Text(formatTime(widget.data.initialTimes[i]))
                                ]
                              )
                            )
                          )
                        )
                      )
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _SeparateTimesSet {
  together,
  separate;

  factory _SeparateTimesSet.fromData({required bool isSeparate}) {
    return isSeparate ? _SeparateTimesSet.separate : _SeparateTimesSet.together;
  }

  factory _SeparateTimesSet.fromStr({required String inputStr}) {
    return inputStr == 'Separate'
        ? _SeparateTimesSet.separate
        : _SeparateTimesSet.together;
  }

  String get label {
    switch (this) {
      case _SeparateTimesSet.together:
        return "Together";
      case _SeparateTimesSet.separate:
        return "Separate";
    }
  }

  FormBuilderFieldOption<String> getOption(BuildContext context) {
    return FormBuilderFieldOption<String>(
      value: label,
      child: Text(
        label,
        style: TextStyle(
          color: ThemeHelper.dialogForeground(context),
        ),
      ),
    );
  }
}
