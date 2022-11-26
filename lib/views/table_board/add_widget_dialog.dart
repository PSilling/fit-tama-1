import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

class AddDialog extends StatelessWidget {
  const AddDialog({Key? key}) : super(key: key);

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
                    "Add widget",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: ThemeHelper.dialogForeground(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "One position wide widgets",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: ThemeHelper.dialogForeground(context),
                    ),
                  ),
                ),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ThemeHelper.buttonPrimary(
                        context: context,
                        label: "Counter",
                        onPressed: () {
                          Navigator.pop(context, ['counter', 1]);
                        },
                      ),
                      ThemeHelper.buttonPrimary(
                        context: context,
                        label: "Dice",
                        onPressed: () {
                          Navigator.pop(context, ['dice', 1]);
                        },
                      ),
                      ThemeHelper.buttonPrimary(
                        context: context,
                        label: "Timer",
                        onPressed: () {
                          Navigator.pop(context, ['timer', 1]);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Two positions wide widgets",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: ThemeHelper.dialogForeground(context),
                    ),
                  ),
                ),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ThemeHelper.buttonPrimary(
                        context: context,
                        label: "Counter",
                        onPressed: () {
                          Navigator.pop(context, ['counter', 2]);
                        },
                      ),
                      ThemeHelper.buttonPrimary(
                        context: context,
                        label: "Chess Timer",
                        onPressed: () {
                          Navigator.pop(context, ['chess_timer', 2]);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}