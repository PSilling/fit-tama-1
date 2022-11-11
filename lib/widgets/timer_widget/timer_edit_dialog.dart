import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/extensions.dart';
import '../../util/themes.dart';
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
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () => FocusScope.of(context).unfocus(),
        child: AlertDialog(
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
                    textInputAction: TextInputAction.next,
                    initialValue: data.name,
                    onSaved: (value) => data.name = value ?? "",
                  ),
                  FormBuilderTextField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
                    name: "initial_time",
                    decoration: ThemeHelper.formInputDecoration(context, label: "Initial time"),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    initialValue: "${data.initialTime}",
                    validator: _numberValidator,
                    onSaved: (value) => data.initialTime = int.parse(value!),
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
