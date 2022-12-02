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
      backgroundColor: ThemeHelper.dialogBackground(context),
      contentTextStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: ThemeHelper.dialogForeground(context)),
      titleTextStyle: Theme.of(context).textTheme.headline6!.copyWith(color: ThemeHelper.dialogForeground(context)),
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
