import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/extensions.dart';
import '../../util/themes.dart';
import 'chess_timer_widget_data.dart';

class ChessTimerEditDialog extends StatefulWidget {
  final ChessTimerWidgetData data;
  final void Function(ChessTimerWidgetData) setData;

  const ChessTimerEditDialog({super.key, required this.data, required this.setData});

  @override
  State<StatefulWidget> createState() => ChessTimerEditDialogState();
}

class ChessTimerEditDialogState extends State<ChessTimerEditDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<int> _numTimersPossible = [2, 3];
  late _SeparateTimesSet _separateTimeSet;
  late List<int> _outputs;

  late List<FormBuilderTextField> timeInputFields;

  @override
  void initState(){
    _separateTimeSet = _SeparateTimesSet.fromData(isSeparate: widget.data.isSeparate);
    _outputs = List<int>.generate(_numTimersPossible.reduce(max), (index) => 0);
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

      if (_separateTimeSet == _SeparateTimesSet.together){
        widget.data.initialTimes = List
            .generate(widget.data.initialTimes.length, (index) => _outputs[0]);
      } else {
        for(var i = 0; i < widget.data.initialTimes.length; i++){
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
                decoration: ThemeHelper.dialogInputDecoration(context, label: "Title"),
                textInputAction: TextInputAction.next,
                initialValue: widget.data.name,
                onSaved: (value) => widget.data.name = value ?? "",
              ),
              FormBuilderRadioGroup<String>(
                  activeColor: ThemeHelper.dialogForeground(context),
                  decoration: ThemeHelper.dialogInputDecoration(context, label: "Number of timers"),
                  name: "num_timers",
                  initialValue: widget.data.initialTimes.length.toString(),
                  onChanged: (val) {
                    if (val != null){
                      while(int.parse(val) > widget.data.initialTimes.length){
                        widget.data.initialTimes.add(widget.data.initialTimes[0]);
                      }
                      while(int.parse(val) < widget.data.initialTimes.length){
                        widget.data.initialTimes.removeAt(widget.data.initialTimes.length - 1);
                      }
                      setState(() {});
                    }
                  },
                  options: List<FormBuilderFieldOption<String>>.generate(_numTimersPossible.length,
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
                    })
              ),
              FormBuilderRadioGroup<String>(
                  activeColor: ThemeHelper.dialogForeground(context),
                  decoration: ThemeHelper.dialogInputDecoration(context, label: "Scale"),
                  name: "timer_ranges",
                  initialValue: _separateTimeSet.label,
                  onChanged: (value) {
                    if(value != null){
                      _separateTimeSet = _SeparateTimesSet.fromStr(inputStr: value);
                      setState(() {});
                    }
                  },
                  //onSaved: (value) => widget.data.isUneven = _EvennessOptions.isUneven(value: value),
                  options: [
                    _SeparateTimesSet.together.getOption(context),
                    _SeparateTimesSet.separate.getOption(context),
                  ]
              ),
              for(var i = 0; i < _numTimersPossible.reduce(max); i++)
                Visibility(
                  visible: i < 1 || (_separateTimeSet == _SeparateTimesSet.separate && i < widget.data.initialTimes.length),
                  child:
                  FormBuilderTextField(
                    style: TextStyle(
                    color: ThemeHelper.dialogForeground(context),
                    ),
                    cursorColor: ThemeHelper.dialogForeground(context),
                    name: "initial_time_$i",
                    decoration: ThemeHelper.dialogInputDecoration(context, label: "Initial time of player ${i+1}"),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    initialValue: i < widget.data.initialTimes.length ? "${widget.data.initialTimes[i]}" : "",
                    validator: _numberValidator,
                    onSaved: (value) {_outputs[i] = int.parse(value!);}
                  )
                )
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

  factory _SeparateTimesSet.fromStr({required String inputStr}){
    return inputStr == 'Separate' ? _SeparateTimesSet.separate :
        _SeparateTimesSet.together;
  }

  String get label {
    switch (this) {
      case _SeparateTimesSet.together:
        return "Together";
      case _SeparateTimesSet.separate:
        return "Separate";
    }
  }

  static bool isSeparate({required String? value}) {
    return value == _SeparateTimesSet.separate.label;
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
