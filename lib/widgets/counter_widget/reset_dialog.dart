import 'package:flutter/material.dart';

class ResetDialog extends StatelessWidget {
  final void Function() resetIndex;
  final int? originalValue;

  const ResetDialog(
      {super.key, required this.originalValue, required this.resetIndex});

  @override
  Widget build(BuildContext context) {
    final String titleEnding;
    if (originalValue != null) {
      titleEnding = " of $originalValue?";
    } else {
      titleEnding = "?";
    }
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
