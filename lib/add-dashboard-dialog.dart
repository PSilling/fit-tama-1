import 'package:flutter/material.dart';

class AddDashboardDialog extends StatefulWidget {
  const AddDashboardDialog({Key? key}) : super(key: key);

  @override
  State<AddDashboardDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDashboardDialog> {

  final textController = TextEditingController();
  String? name;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

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
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'New board name'
                  )
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, textController.text);
                    },
                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                      child: Text("Add"),
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
