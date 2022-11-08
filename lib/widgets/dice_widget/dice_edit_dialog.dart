import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../helpers/extensions.dart';
import '../../themes.dart';
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
                  name: "name",
                  decoration: ThemeHelper.textInputDecoration(context, "Title"),
                  initialValue: data.name,
                  onSaved: (value) => data.name = value ?? "",
                ),
                FormBuilderTextField(
                  name: "number_of_dice",
                  decoration: ThemeHelper.textInputDecoration(context, "Dice count"),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  initialValue: "${data.numberOfDice}",
                  validator: (value) => _numberValidator(value, minimalValue: 1),
                  onSaved: (value) => data.numberOfDice = int.parse(value!),
                ),
                FormBuilderTextField(
                  name: "number_of_sides",
                  decoration: ThemeHelper.textInputDecoration(context, "Side count"),
                  keyboardType:  const TextInputType.numberWithOptions(signed: true),
                  initialValue: "${data.numberOfSides}",
                  validator: (value) => _numberValidator(value, minimalValue: 2),
                  onSaved: (value) => data.numberOfSides = int.parse(value!),
                ),
                FormBuilderCheckbox(
                  activeColor: Theme.of(context).colorScheme.onBackground,
                  checkColor: Theme.of(context).colorScheme.primary,
                  name: "long_press_required",
                  title: const Text("Long press to reroll"),
                  initialValue: data.longPressToReroll,
                  onSaved: (value) => data.longPressToReroll = value!,
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
