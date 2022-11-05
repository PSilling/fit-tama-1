import 'package:board_aid/themes.dart';
import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({Key? key}) : super(key: key);

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ThemeHelper.buttonPrimary(
                  context: context,
                  label: "Counter",
                  onPressed: () {
                    Navigator.pop(context, 'counter');
                  },
                ),
                ThemeHelper.buttonPrimary(
                  context: context,
                  label: "Dice",
                  onPressed: () {
                    Navigator.pop(context, 'dice');
                  },
                ),
                ThemeHelper.buttonPrimary(
                  context: context,
                  label: "Timer",
                  onPressed: () {
                    Navigator.pop(context, 'timer');
                  },
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
