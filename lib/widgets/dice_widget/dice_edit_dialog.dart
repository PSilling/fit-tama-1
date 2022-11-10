import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/extensions.dart';
import '../../util/themes.dart';
import 'dice_widget_data.dart';

class DiceEditDialog extends StatelessWidget {
  final DiceWidgetData data;
  final void Function(DiceWidgetData) setData;

  DiceEditDialog({super.key, required this.data, required this.setData});

  final _formKey = GlobalKey<FormBuilderState>();

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

  void _validateSaveAndDismiss(BuildContext context) {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }
    if (formState.validate()) {
      formState.save();
      setData(data);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: FormBuilder(
              key: _formKey,
              child: Column(children: [
                FormBuilderTextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  cursorColor: Theme.of(context).colorScheme.onSurface,
                  name: "name",
                  decoration: ThemeHelper.formInputDecoration(context, label: "Title"),
                  initialValue: data.name,
                  onSaved: (value) => data.name = value ?? "",
                ),
                FormBuilderTextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  cursorColor: Theme.of(context).colorScheme.onSurface,
                  name: "number_of_dice",
                  decoration: ThemeHelper.formInputDecoration(context, label: "Dice count"),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  initialValue: "${data.numberOfDice}",
                  validator: (value) => _numberValidator(value, minimalValue: 1),
                  onSaved: (value) => data.numberOfDice = int.parse(value!),
                ),
                FormBuilderTextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  cursorColor: Theme.of(context).colorScheme.onSurface,
                  name: "number_of_sides",
                  decoration: ThemeHelper.formInputDecoration(context, label: "Side count"),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  initialValue: "${data.numberOfSides}",
                  validator: (value) => _numberValidator(value, minimalValue: 2),
                  onSaved: (value) => data.numberOfSides = int.parse(value!),
                ),
                FormBuilderChoiceChip<String>(
                  decoration: ThemeHelper.formInputDecoration(context, label: "Action to reroll"),
                  spacing: ThemeHelper.widgetDialogChipSpacing,
                  name: "reroll_action",
                  initialValue: _RerollOptions.fromData(longPressToReroll: data.longPressToReroll).label,
                  onSaved: (value) => data.longPressToReroll = _RerollOptions.isLongPressToReroll(value: value),
                  options: [
                    _RerollOptions.tap.option,
                    _RerollOptions.longpress.option,
                  ],
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
      );
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

  get option => FormBuilderChipOption<String>(value: label);
}
