import 'package:flutter/material.dart';

import '../../../util/extensions.dart';
import '../../../util/themes.dart';

class CounterScaleDialog extends StatefulWidget {
  final void Function(IndexedEntry) setCurrentIndex;
  final List<IndexedEntry> scale;
  final IndexedEntry currentEntry;
  final IndexedEntry defaultEntry;

  const CounterScaleDialog._private(
      {super.key,
      required this.scale,
      required this.currentEntry,
      required this.defaultEntry,
      required this.setCurrentIndex});

  factory CounterScaleDialog(
      {Key? key,
      required int currentIndex,
      required int defaultIndex,
      required int scaleLength,
      required void Function(int) setCurrentIndex,
      required Widget Function(int) getNumberWidgetAt,
      required bool isLeftDeath,
      required bool isRightDeath}) {
    final List<IndexedEntry> leftDeathEntry = isLeftDeath
        ? [IndexedEntry.from(index: -1, getNumberAt: getNumberWidgetAt)]
        : [];
    final List<IndexedEntry> rightDeathEntry = isRightDeath
        ? [
            IndexedEntry.from(
                index: scaleLength, getNumberAt: getNumberWidgetAt)
          ]
        : [];
    final entryScale = List.generate(
        scaleLength,
        (index) =>
            IndexedEntry(index: index, widget: getNumberWidgetAt(index)));
    final fullScale = leftDeathEntry + entryScale + rightDeathEntry;
    final currentEntry =
        fullScale.getEntry(at: currentIndex, isLeftDeath: isLeftDeath);
    final defaultEntry =
        fullScale.getEntry(at: defaultIndex, isLeftDeath: isLeftDeath);
    return CounterScaleDialog._private(
      key: key,
      scale: fullScale,
      currentEntry: currentEntry,
      defaultEntry: defaultEntry,
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => Scrollable.ensureVisible(
              widget.currentEntry.key.currentContext!,
              alignment: 0.5,
            ));
  }

  ButtonStyle? _getButtonStyle({required IndexedEntry entry}) {
    const minSize = Size(55, 55);
    final textStyle = Theme.of(context).textTheme.headlineSmall;
    Color? foregroundColor = ThemeHelper.dialogForeground(context);
    Color? backgroundColor;
    bool isBold = false;
    bool hasBorder = false;
    if (entry == widget.currentEntry) {
      hasBorder = true;
    }
    if (entry == _selectedEntry) {
      foregroundColor = ThemeHelper.dialogBackground(context);
      backgroundColor = ThemeHelper.dialogForeground(context);
    }
    if (entry == widget.defaultEntry) {
      foregroundColor = ThemeHelper.dialogForegroundHighlight(context);
      isBold = true;
    }
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      side: hasBorder ? BorderSide(width: 2, color: ThemeHelper.dialogForeground(context)) : BorderSide.none,
      minimumSize: minSize,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: textStyle?.copyWith(fontWeight: isBold ? FontWeight.w600 : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeHelper.dialogBackground(context),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: widget.scale.map((entry) {
            return OutlinedButton(
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
        ThemeHelper.buttonPrimary(
          context: context,
          onPressed: _selectedEntry.flatMap((entry) => () {
                widget.setCurrentIndex(entry);
                Navigator.of(context).pop();
              }),
          label: "Confirm",
        ),
        ThemeHelper.buttonSecondary(
          context: context,
          onPressed: () => Navigator.of(context).pop(),
          label: "Cancel",
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

  factory IndexedEntry.from(
      {required int index, required Widget Function(int) getNumberAt}) {
    return IndexedEntry(index: index, widget: getNumberAt(index));
  }
}

extension _IndexedEntryList on List<IndexedEntry> {
  IndexedEntry getEntry({required int at, required bool isLeftDeath}) =>
      this[at + (isLeftDeath ? 1 : 0)];
}
