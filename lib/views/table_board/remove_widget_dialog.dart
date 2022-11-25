import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

class RemoveDialog extends StatelessWidget {
  const RemoveDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeHelper.dialogBackground(context),
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Remove all your widgets?",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: ThemeHelper.dialogForeground(context),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ThemeHelper.buttonPrimary(
                      context: context,
                      label: "Yes",
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                    ThemeHelper.buttonSecondary(
                      context: context,
                      label: "Cancel",
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
