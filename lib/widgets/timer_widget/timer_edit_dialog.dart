import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../helpers.dart';
import 'timer_widget_data.dart';

class TimerEditDialog extends StatelessWidget {
  final TimerWidgetData data;
  final void Function(TimerWidgetData) setData;

  TimerEditDialog({super.key, required this.data, required this.setData});

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
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. "Turn Timer"',
                  ),
                  initialValue: data.name,
                  onSaved: (value) => data.name = value ?? "",
                ),
                FormBuilderTextField(
                  name: "initial_time",
                  decoration: const InputDecoration(
                    labelText: 'Initial time',
                    hintText: 'e.g. 20 (time is in seconds)',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: "${data.initialTime}",
                  validator: _numberValidator,
                  onSaved: (value) => data.initialTime = int.parse(value!),
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
