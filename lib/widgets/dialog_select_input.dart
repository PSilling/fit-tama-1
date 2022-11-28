import 'package:flutter/material.dart';

import '../util/icons.dart';
import '../util/themes.dart';

/// Input for selecting items via a popup dialog.
class DialogSelectInput extends StatelessWidget {
  const DialogSelectInput({
    super.key,
    required this.value,
    required this.onSelected,
    required this.itemLabelMap,
    required this.itemBuilder,
    this.defaultValue,
    this.label,
    this.dialogTitle,
    this.iconCode,
    this.iconColor,
    this.iconSize,
    this.heightDivisor = 2,
    this.itemsPerRow = 6,
  });

  final dynamic value;
  final Function(dynamic item) onSelected;
  final Map<dynamic, String> itemLabelMap;
  final Widget Function(dynamic element) itemBuilder;
  final dynamic defaultValue;
  final String? label;
  final String? dialogTitle;
  final int? iconCode;
  final Color? iconColor;
  final double? iconSize;
  final double heightDivisor;
  final int itemsPerRow;

  /// Opens the icon selection dialog.
  void _openSelectDialog(BuildContext context) {
    var sortedItems = itemLabelMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    var dialogChildren = <Widget>[
      Expanded(
        child: GridView.builder(
          padding: EdgeInsets.all(ThemeHelper.selectDialogItemSpacing()),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemsPerRow,
            childAspectRatio: 1,
            crossAxisSpacing: ThemeHelper.selectDialogItemSpacing() / 2,
            mainAxisSpacing: ThemeHelper.selectDialogItemSpacing() / 2,
          ),
          itemCount: sortedItems.length,
          itemBuilder: (BuildContext context, index) {
            var item = sortedItems[index].key;
            return InkResponse(
              onTap: () {
                onSelected(item);
                Navigator.pop(context);
              },
              child: itemBuilder(item),
            );
          },
        ),
      ),
    ];

    if (defaultValue != null) {
      dialogChildren.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Default:"),
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8),
              child: InkResponse(
                onTap: () {
                  onSelected(null);
                  Navigator.pop(context);
                },
                child: itemBuilder(defaultValue),
              ),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          dialogTitle ?? 'Select item',
          style: TextStyle(
            color: ThemeHelper.dialogForeground(context),
          ),
        ),
        backgroundColor: ThemeHelper.dialogBackground(context),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / heightDivisor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: dialogChildren,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: InputDecorator(
        decoration: ThemeHelper.editViewInputDecoration(context).copyWith(
          labelText: label,
          prefixIcon: iconFromCode(
            iconCode: iconCode ?? 0xe046,
            color: iconColor,
            size: iconSize,
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          prefixText: value == null ? "Default" : itemLabelMap[value],
        ),
      ),
      onTap: () => _openSelectDialog(context),
    );
  }
}
