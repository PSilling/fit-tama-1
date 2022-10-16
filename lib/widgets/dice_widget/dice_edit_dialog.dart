import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tabletop_assistant/widgets/dice_widget/dice_widget_data.dart';
import 'package:tabletop_assistant/helpers.dart';

class DiceEditDialog extends StatelessWidget {
  final DiceWidgetData data;
  final void Function(DiceWidgetData) setData;

  DiceEditDialog({super.key, required this.data, required this.setData});

  final _formKey = GlobalKey<FormBuilderState>();

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
      setData(data);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: FormBuilder(
              key: _formKey,
              child: Column(children: [
                FormBuilderTextField(
                  name: "name",
                  initialValue: data.name,
                  onSaved: (value) => data.name = value ?? "",
                ),
                FormBuilderTextField(
                  name: "number_of_dice",
                  keyboardType: TextInputType.number,
                  initialValue: "${data.numberOfDice}",
                  validator: _numberValidator,
                  onSaved: (value) => data.numberOfDice = int.parse(value!),
                ),
                FormBuilderTextField(
                  name: "number_of_sides",
                  keyboardType: TextInputType.number,
                  initialValue: "${data.numberOfSides}",
                  validator: _numberValidator,
                  onSaved: (value) => data.numberOfSides = int.parse(value!),
                ),
                FormBuilderCheckbox(
                  name: "long_press_required",
                  title: const Text("Long press to reroll"),
                  initialValue: data.longPressToReroll,
                  onSaved: (value) => data.longPressToReroll = value!,
                )
              ]),
            )),
        actions: [
          TextButton(
            onPressed: () => _validateSaveAndDismiss(context),
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      );
}