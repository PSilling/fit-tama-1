import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({Key? key}) : super(key: key);

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text("Add widget"),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, 'counter');
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                      child: Text("Add Counter"),
                    )),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, 'dice');
                    },
                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                      child: Text("Add Dice"),
                    )),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, 'timer');
                    },
                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                      child: Text("Add Timer"),
                    )),
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
