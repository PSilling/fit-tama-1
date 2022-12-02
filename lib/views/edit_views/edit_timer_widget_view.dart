import 'dart:async';

import 'package:board_aid/util/extensions.dart';
import 'package:board_aid/widgets/timer_widget/timer_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/themes.dart';
import '../../widgets/dialog_select_input.dart';
import '../../widgets/timer_widget/timer_widget_data.dart';

class EditTimerWidgetView extends StatefulWidget {
  final TimerWidgetData data;
  final void Function(TimerWidgetData) setData;

  const EditTimerWidgetView({
    super.key,
    required this.data,
    required this.setData,
  });

  @override
  State<EditTimerWidgetView> createState() => _EditTimerWidgetViewState();
}

class _EditTimerWidgetViewState extends State<EditTimerWidgetView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<TimerWidgetState> _previewKey = GlobalKey<TimerWidgetState>();

  /// Handles navigator pop and dice widget data saving on back button press.
  Future<bool> _onWillPop() {
    _validateAndSave();
    return Future.value(true);
  }

  /// Validates form inputs and saves if possible.
  void _validateAndSave() {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      widget.setData(widget.data);
      _previewKey.currentState!.reset();
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
        MediaQuery.of(context).size.width / 2 - 2 * ThemeHelper.cardSpacing();
    final previewHeight = previewWidth;
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
                      child: TimerWidget(
                        key: _previewKey,
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
                    child: FormBuilderChoiceChip<String>(
                      backgroundColor: ThemeHelper.dialogForeground(context)
                          .withOpacity(0.5),
                      selectedColor: ThemeHelper.dialogForeground(context),
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Behavior when the timer is up"),
                      spacing: ThemeHelper.dialogChipSpacing,
                      name: "count_negative",
                      initialValue: _NegativeTimeOptions.fromData(
                        cont: widget.data.countNegative,
                      ).label,
                      onSaved: (value) => widget.data.countNegative =
                          _NegativeTimeOptions.countNegative(value: value),
                      options: [
                        _NegativeTimeOptions.cont.getOption(context),
                        _NegativeTimeOptions.stop.getOption(context),
                      ],
                      onChanged: (value) {
                        _validateAndSave();
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: GestureDetector(
                      onTap: () => _showDialog(
                        CupertinoTimerPicker(
                          initialTimerDuration: Duration(seconds: widget.data.initialTime),
                          onTimerDurationChanged: (value) {
                            widget.data.initialTime = value.inSeconds;
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
                              Text(
                                'Initial time:',
                                style: TextStyle(
                                  color: ThemeHelper.editViewForeground(context)
                                ),
                              ),
                              Text(
                                formatTime(widget.data.initialTime),
                                style: TextStyle(
                                    color: ThemeHelper.editViewForeground(context)
                                ),
                              )
                            ]
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

enum _NegativeTimeOptions {
  cont,
  stop;

  factory _NegativeTimeOptions.fromData({required bool cont}) {
    return cont ? _NegativeTimeOptions.cont : _NegativeTimeOptions.stop;
  }

  String get label {
    switch (this) {
      case _NegativeTimeOptions.stop:
        return "Stop the timer";
      case _NegativeTimeOptions.cont:
        return "Continue";
    }
  }

  static bool countNegative({required String? value}) {
    return value == _NegativeTimeOptions.cont.label;
  }

  FormBuilderChipOption<String> getOption(BuildContext context) {
    return FormBuilderChipOption<String>(
      value: label,
      child: Text(
        label,
        style: TextStyle(
          color: ThemeHelper.dialogBackground(context),
        ),
      ),
    );
  }
}
