import 'package:flutter/material.dart';

import '../../../helpers/extensions.dart';
import '../../../themes.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
      title: Text("Reset counter to original value$titleEnding"),
      actions: [
        ThemeHelper.buttonWarn(
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
