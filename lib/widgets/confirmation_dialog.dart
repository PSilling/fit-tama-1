import 'package:flutter/material.dart';

/// General purpose confirmation dialog.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.onConfirm,
    this.title = 'Are you sure?',
    this.confirmText = 'Confirm',
    this.message = '',
  });

  final Function onConfirm;
  final String title;
  final String message;
  final String confirmText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context, confirmText);
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
