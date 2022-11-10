import 'package:flutter/material.dart';

import '../util/themes.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
      title: Text(title),
      content: Text(message),
      actions: [
        ThemeHelper.buttonPrimary(
          context: context,
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          label: confirmText,
        ),
        ThemeHelper.buttonSecondary(
          context: context,
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancel',
        ),
      ],
    );
  }
}
