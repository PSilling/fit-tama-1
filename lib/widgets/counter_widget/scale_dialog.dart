import 'dart:math';

import 'package:flutter/material.dart';

class ScaleDialog extends StatefulWidget {
  final void Function(NumberEntry) setCurrentIndex;
  final List<NumberEntry> scale;
  final NumberEntry currentEntry;

  const ScaleDialog._private(
      {super.key,
      required this.scale,
      required this.currentEntry,
      required this.setCurrentIndex});

  factory ScaleDialog(
      {Key? key,
      required int currentIndex,
      required void Function(int) setCurrentIndex,
      required List<int> scale}) {
    final entryScale = scale
        .asMap()
        .entries
        .map((entry) => NumberEntry(index: entry.key, number: entry.value))
        .toList();
    return ScaleDialog._private(
      key: key,
      scale: entryScale,
      currentEntry: entryScale[currentIndex],
      setCurrentIndex: (entry) => setCurrentIndex(entry.index),
    );
  }

  @override
  State<StatefulWidget> createState() => ScaleDialogState();
}

class ScaleDialogState extends State<ScaleDialog> {
  NumberEntry? selectedEntry;

  ButtonStyle? getButtonStyle({required NumberEntry entry}) {
    const minSize = Size(50, 0);
    final textStyle = Theme.of(context).textTheme.headlineSmall;
    final normal = TextButton.styleFrom(
        minimumSize: minSize,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: textStyle);
    final selected = TextButton.styleFrom(
        minimumSize: minSize,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        textStyle: textStyle);
    final current = TextButton.styleFrom(
        minimumSize: minSize,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: Colors.black,
        textStyle: textStyle);
    if (entry == widget.currentEntry) {
      return current;
    } else if (entry == selectedEntry) {
      return selected;
    } else {
      return normal;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => Scrollable.ensureVisible(
              widget.currentEntry.key.currentContext!,
              alignment: 0.5,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: widget.scale.map((entry) {
            return TextButton(
              key: entry.key,
              onPressed: () {
                setState(() {
                  if (selectedEntry == entry || widget.currentEntry == entry) {
                    selectedEntry = null;
                  } else {
                    selectedEntry = entry;
                  }
                });
              },
              style: getButtonStyle(entry: entry),
              child: Text("${entry.number}"),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: selectedEntry != null
              ? () {
                  widget.setCurrentIndex(selectedEntry!);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text("Confirm"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}

class NumberEntry {
  final key = GlobalKey();
  final int index;
  final int number;

  NumberEntry({required this.index, required this.number});
}
