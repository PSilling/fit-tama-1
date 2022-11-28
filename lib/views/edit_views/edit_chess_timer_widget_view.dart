import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/extensions.dart';
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
  late Timer _updateTimer;

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
    _updateTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        setState(() {
          _validateAndSave();
        });
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  /// Handles navigator pop and dice widget data saving on back button press.
  Future<bool> _onWillPop() {
    _validateAndSave();
    return Future.value(true);
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
    }
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
                        initData: widget.data,
                        startEditing: false,
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
                      textInputAction: TextInputAction.next,
                      initialValue: widget.data.name,
                      onSaved: (value) => widget.data.name = value ?? "",
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
                        label: "Scale",
                      ),
                      name: "timer_ranges",
                      initialValue: _separateTimeSet.label,
                      onChanged: (value) {
                        if (value != null) {
                          _separateTimeSet =
                              _SeparateTimesSet.fromStr(inputStr: value);
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
                        child: FormBuilderTextField(
                          style: TextStyle(
                            color: ThemeHelper.dialogForeground(context),
                          ),
                          cursorColor: ThemeHelper.dialogForeground(context),
                          name: "initial_time_$i",
                          decoration: ThemeHelper.dialogInputDecoration(context,
                              label:
                                  _separateTimeSet == _SeparateTimesSet.separate
                                      ? 'Initial time of player ${i + 1}'
                                      : 'Initial time of all timers'),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          initialValue: '${_outputs[i]}',
                          validator: _numberValidator,
                          onSaved: (value) {
                            _outputs[i] = int.parse(value!);
                          },
                        ),
                      ),
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
