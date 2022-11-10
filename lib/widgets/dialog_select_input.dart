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
    this.label,
    this.dialogTitle,
    this.iconCode,
    this.iconColor,
    this.iconSize,
  });

  final dynamic value;
  final Function(dynamic item) onSelected;
  final Map<dynamic, String> itemLabelMap;
  final Widget Function(dynamic element) itemBuilder;
  final String? label;
  final String? dialogTitle;
  final int? iconCode;
  final Color? iconColor;
  final double? iconSize;

  /// Opens the icon selection dialog.
  void _openSelectDialog(BuildContext context) {
    var sortedItems = itemLabelMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(dialogTitle ?? 'Select item'),
        backgroundColor: Theme.of(context).colorScheme.background,
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
          child: GridView.builder(
            padding: EdgeInsets.all(ThemeHelper.selectDialogItemSpacing()),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: iconFromCode(
            iconCode: iconCode ?? 0xe046,
            color: iconColor,
            size: iconSize,
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          prefixText: itemLabelMap[value],
        ),
      ),
      onTap: () => _openSelectDialog(context),
    );
  }
}
