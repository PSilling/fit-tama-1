import 'package:flutter/material.dart';
import 'package:tabletop_assistant/helpers.dart';

class CounterScaleDialog extends StatefulWidget {
  final void Function(IndexedEntry) setCurrentIndex;
  final List<IndexedEntry> scale;
  final IndexedEntry currentEntry;

  const CounterScaleDialog._private(
      {super.key, required this.scale, required this.currentEntry, required this.setCurrentIndex});

  factory CounterScaleDialog(
      {Key? key,
      required int currentIndex,
      required int scaleLength,
      required void Function(int) setCurrentIndex,
      required Widget Function(int) getNumberWidgetAt,
      required bool isLeftDeath,
      required bool isRightDeath}) {
    final List<IndexedEntry> leftDeathEntry =
        isLeftDeath ? [IndexedEntry.from(index: -1, getNumberAt: getNumberWidgetAt)] : [];
    final List<IndexedEntry> rightDeathEntry =
        isRightDeath ? [IndexedEntry.from(index: scaleLength, getNumberAt: getNumberWidgetAt)] : [];
    final entryScale =
        List.generate(scaleLength, (index) => IndexedEntry(index: index, widget: getNumberWidgetAt(index)));
    final fullScale = leftDeathEntry + entryScale + rightDeathEntry;
    final currentEntry = fullScale[currentIndex + (isLeftDeath ? 1 : 0)];
    return CounterScaleDialog._private(
      key: key,
      scale: fullScale,
      currentEntry: currentEntry,
      setCurrentIndex: (entry) => setCurrentIndex(entry.index),
    );
  }

  @override
  State<StatefulWidget> createState() => _CounterScaleDialogState();
}

class _CounterScaleDialogState extends State<CounterScaleDialog> {
  IndexedEntry? _selectedEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Scrollable.ensureVisible(
          widget.currentEntry.key.currentContext!,
          alignment: 0.5,
        ));
  }

  ButtonStyle? _getButtonStyle({required IndexedEntry entry}) {
    const minSize = Size(50, 0);
    final textStyle = Theme.of(context).textTheme.headlineSmall;
    final normal = TextButton.styleFrom(
        minimumSize: minSize, tapTargetSize: MaterialTapTargetSize.shrinkWrap, textStyle: textStyle);
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
    } else if (entry == _selectedEntry) {
      return selected;
    } else {
      return normal;
    }
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
                  if (_selectedEntry == entry || widget.currentEntry == entry) {
                    _selectedEntry = null;
                  } else {
                    _selectedEntry = entry;
                  }
                });
              },
              style: _getButtonStyle(entry: entry),
              child: entry.widget,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _selectedEntry.flatMap((entry) => () {
                widget.setCurrentIndex(entry);
                Navigator.of(context).pop();
              }),
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

class IndexedEntry {
  final key = GlobalKey();
  final int index;
  final Widget widget;

  IndexedEntry({required this.index, required this.widget});

  factory IndexedEntry.from({required int index, required Widget Function(int) getNumberAt}) {
    return IndexedEntry(index: index, widget: getNumberAt(index));
  }
}
