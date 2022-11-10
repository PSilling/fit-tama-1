import 'package:flutter/material.dart';

/// Application bar for customize preset view.
class CustomizePresetAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomizePresetAppbar({
    super.key,
    required this.onSave,
    required this.onRevert,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;
  final Function() onSave;
  final Function() onRevert;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Customize Preset'),
      actions: [
        IconButton(
          onPressed: onSave,
          icon: const Icon(Icons.save),
        ),
        IconButton(
          onPressed: onRevert,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
