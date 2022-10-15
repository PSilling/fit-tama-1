import 'package:flutter/material.dart';
import 'package:tabletop_assistant/helpers.dart';

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
      title: Text("Reset counter to original value$titleEnding"),
      actions: [
        TextButton(
          onPressed: () {
            resetIndex();
            Navigator.of(context).pop();
          },
          child: const Text("Yes"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        )
      ],
    );
  }
}
