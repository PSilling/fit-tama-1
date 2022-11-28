import 'dart:async';

import 'package:board_aid/widgets/timer_widget/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/extensions.dart';
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
  late Timer _updateTimer;

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
    if (formState != null && formState.validate()) {
      formState.save();
      widget.setData(widget.data);
    }
  }

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        setState(() {
          _validateAndSave();
        });
      },
    );
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
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
                    child: FormBuilderTextField(
                      style: TextStyle(
                        color: ThemeHelper.dialogForeground(context),
                      ),
                      cursorColor: ThemeHelper.dialogForeground(context),
                      name: "initial_time",
                      decoration: ThemeHelper.dialogInputDecoration(
                        context,
                        label: "Initial time",
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      initialValue: "${widget.data.initialTime}",
                      validator: _numberValidator,
                      onSaved: (value) =>
                          widget.data.initialTime = int.parse(value!),
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
