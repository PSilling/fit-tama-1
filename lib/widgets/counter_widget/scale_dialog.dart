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
      required int scaleLength,
      required void Function(int) setCurrentIndex,
      required Widget Function(int) getNumberWidgetAt,
      required bool isLeftDeath,
      required bool isRightDeath}) {
    final List<NumberEntry> leftDeathEntry = isLeftDeath
        ? [NumberEntry.from(index: -1, getNumberAt: getNumberWidgetAt)]
        : [];
    final List<NumberEntry> rightDeathEntry = isRightDeath
        ? [NumberEntry.from(index: scaleLength, getNumberAt: getNumberWidgetAt)]
        : [];
    final entryScale = List.generate(scaleLength,
        (index) => NumberEntry(index: index, widget: getNumberWidgetAt(index)));
    final fullScale = leftDeathEntry + entryScale + rightDeathEntry;
    final currentEntry = fullScale[currentIndex + (isLeftDeath ? 1 : 0)];
    return ScaleDialog._private(
      key: key,
      scale: fullScale,
      currentEntry: currentEntry,
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
              child: entry.widget,
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
  final Widget widget;

  NumberEntry({required this.index, required this.widget});

  factory NumberEntry.from(
      {required int index, required Widget Function(int) getNumberAt}) {
    return NumberEntry(index: index, widget: getNumberAt(index));
  }
}
