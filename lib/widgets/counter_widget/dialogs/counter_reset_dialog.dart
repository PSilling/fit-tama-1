import 'package:flutter/material.dart';

import '../../../util/extensions.dart';
import '../../../util/themes.dart';

class CounterResetDialog extends StatelessWidget {
  final void Function() resetIndex;
  final int? originalValue;

  const CounterResetDialog(
      {super.key, required this.originalValue, required this.resetIndex});

  @override
  Widget build(BuildContext context) {
    final titleEnding =
        "${originalValue.flatMap((value) => " of $value") ?? ""}?";
    return AlertDialog(
      backgroundColor: ThemeHelper.dialogBackground(context),
      title: Text(
        "Reset counter to original value$titleEnding",
        style: TextStyle(
          color: ThemeHelper.dialogForeground(context)
        ),
      ),
      actions: [
        ThemeHelper.buttonPrimary(
          context: context,
          onPressed: () {
            resetIndex();
            Navigator.of(context).pop();
          },
          label: "Yes",
        ),
        ThemeHelper.buttonSecondary(
          context: context,
          onPressed: () => Navigator.of(context).pop(),
          label: "Cancel",
        ),
      ],
    );
  }
}
