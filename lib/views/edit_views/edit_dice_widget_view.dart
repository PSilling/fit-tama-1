import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/extensions.dart';
import '../../util/themes.dart';
import '../../widgets/dialog_select_input.dart';
import '../../widgets/dice_widget/dice_widget.dart';
import '../../widgets/dice_widget/dice_widget_data.dart';

/// Dice widget customization view.
class EditDiceWidgetView extends StatefulWidget {
  const EditDiceWidgetView({
    super.key,
    required this.data,
    required this.setData,
  });

  final DiceWidgetData data;
  final void Function(DiceWidgetData) setData;

  @override
  State<EditDiceWidgetView> createState() => _EditDiceWidgetViewState();
}

class _EditDiceWidgetViewState extends State<EditDiceWidgetView> {
  final _formKey = GlobalKey<FormBuilderState>();
  late Timer _updateTimer;

  /// Handles navigator pop and dice widget data saving on back button press.
  Future<bool> _onWillPop() {
    _validateAndSave();
    return Future.value(true);
  }

  String? _numberValidator(String? value, {int? minimalValue}) {
    final number = value.flatMap((value) => int.tryParse(value));
    if (number == null) {
      return "This field has to contain numbers only";
    }
    if (minimalValue != null && number < minimalValue) {
      return "It has to be greater than ${minimalValue - 1}";
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
                      child: DiceWidget(
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
                      name: "number_of_dice",
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Dice count"),
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      textInputAction: TextInputAction.next,
                      initialValue: "${widget.data.numberOfDice}",
                      validator: (value) =>
                          _numberValidator(value, minimalValue: 1),
                      onSaved: (value) =>
                          widget.data.numberOfDice = int.parse(value!),
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderTextField(
                      style: TextStyle(
                        color: ThemeHelper.dialogForeground(context),
                      ),
                      cursorColor: ThemeHelper.dialogForeground(context),
                      name: "number_of_sides",
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Side count"),
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      textInputAction: TextInputAction.done,
                      initialValue: "${widget.data.numberOfSides}",
                      validator: (value) =>
                          _numberValidator(value, minimalValue: 2),
                      onSaved: (value) =>
                          widget.data.numberOfSides = int.parse(value!),
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderChoiceChip<String>(
                      backgroundColor: ThemeHelper.dialogForeground(context)
                          .withOpacity(0.5),
                      selectedColor: ThemeHelper.dialogForeground(context),
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Action to reroll"),
                      spacing: ThemeHelper.dialogChipSpacing,
                      name: "reroll_action",
                      initialValue: _RerollOptions.fromData(
                        longPressToReroll: widget.data.longPressToReroll,
                      ).label,
                      onSaved: (value) => widget.data.longPressToReroll =
                          _RerollOptions.isLongPressToReroll(value: value),
                      options: [
                        _RerollOptions.tap.getOption(context),
                        _RerollOptions.longpress.getOption(context),
                      ],
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

enum _RerollOptions {
  tap,
  longpress;

  factory _RerollOptions.fromData({required bool longPressToReroll}) {
    return longPressToReroll ? _RerollOptions.longpress : _RerollOptions.tap;
  }

  String get label {
    switch (this) {
      case _RerollOptions.tap:
        return "Tap";
      case _RerollOptions.longpress:
        return "Longpress";
    }
  }

  static bool isLongPressToReroll({required String? value}) {
    return value == _RerollOptions.longpress.label;
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
