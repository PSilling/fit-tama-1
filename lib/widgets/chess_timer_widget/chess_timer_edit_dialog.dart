import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/extensions.dart';
import '../../util/themes.dart';
import 'chess_timer_widget_data.dart';

class ChessTimerEditDialog extends StatefulWidget {
  final ChessTimerWidgetData data;
  final void Function(ChessTimerWidgetData) setData;

  const ChessTimerEditDialog(
      {super.key, required this.data, required this.setData});

  @override
  State<StatefulWidget> createState() => ChessTimerEditDialogState();
}

class ChessTimerEditDialogState extends State<ChessTimerEditDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
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

  String? _numberValidator(String? value) {
    final number = value.flatMap((value) => int.tryParse(value));
    if (number == null) {
      return "This field has to contain numbers only";
    }
    if (number <= 0) {
      return "It has to be a positive number";
    }
    return null;
  }

  void _validateSaveAndDismiss(BuildContext context) {
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () => FocusScope.of(context).unfocus(),
        child: AlertDialog(
          backgroundColor: ThemeHelper.dialogBackground(context),
          content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FormBuilder(
                key: _formKey,
                child: Column(children: [
                  FormBuilderTextField(
                    style: TextStyle(
                      color: ThemeHelper.dialogForeground(context),
                    ),
                    cursorColor: ThemeHelper.dialogForeground(context),
                    name: "name",
                    decoration: ThemeHelper.dialogInputDecoration(context,
                        label: "Title"),
                    textInputAction: TextInputAction.next,
                    initialValue: widget.data.name,
                    onSaved: (value) => widget.data.name = value ?? "",
                  ),
                  FormBuilderRadioGroup<String>(
                      activeColor: ThemeHelper.dialogForeground(context),
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Number of timers"),
                      name: "num_timers",
                      initialValue: _outputLength.toString(),
                      onChanged: (val) {
                        _outputLength = int.parse(val!);
                        setState(() {});
                      },
                      options: List<FormBuilderFieldOption<String>>.generate(
                          _numTimersPossible.length, (i) {
                        return FormBuilderFieldOption<String>(
                          value: _numTimersPossible[i].toString(),
                          child: Text(
                            _numTimersPossible[i].toString(),
                            style: TextStyle(
                              color: ThemeHelper.dialogForeground(context),
                            ),
                          ),
                        );
                      })),
                  FormBuilderRadioGroup<String>(
                      activeColor: ThemeHelper.dialogForeground(context),
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Scale"),
                      name: "timer_ranges",
                      initialValue: _separateTimeSet.label,
                      onChanged: (value) {
                        if (value != null) {
                          _separateTimeSet =
                              _SeparateTimesSet.fromStr(inputStr: value);
                          setState(() {});
                        }
                      },
                      //onSaved: (value) => widget.data.isUneven = _EvennessOptions.isUneven(value: value),
                      options: [
                        _SeparateTimesSet.together.getOption(context),
                        _SeparateTimesSet.separate.getOption(context),
                      ]),
                  for (var i = 0; i < _numTimersPossible.reduce(max); i++)
                    Visibility(
                        visible: i < 1 ||
                            (_separateTimeSet == _SeparateTimesSet.separate &&
                                i < _outputLength),
                        child: FormBuilderTextField(
                            style: TextStyle(
                              color: ThemeHelper.dialogForeground(context),
                            ),
                            cursorColor: ThemeHelper.dialogForeground(context),
                            name: "initial_time_$i",
                            decoration: ThemeHelper.dialogInputDecoration(
                                context,
                                label: _separateTimeSet ==
                                        _SeparateTimesSet.separate
                                    ? 'Initial time of player ${i + 1}'
                                    : 'Initial time of all timers'),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            initialValue: '${_outputs[i]}',
                            validator: _numberValidator,
                            onSaved: (value) {
                              _outputs[i] = int.parse(value!);
                            }))
                ]),
              )),
          actions: [
            ThemeHelper.buttonPrimary(
              context: context,
              onPressed: () => _validateSaveAndDismiss(context),
              label: "Save",
            ),
            ThemeHelper.buttonSecondary(
              context: context,
              onPressed: () => Navigator.of(context).pop(),
              label: "Cancel",
            ),
          ],
        ),
      );
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
