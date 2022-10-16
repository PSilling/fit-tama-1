import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tabletop_assistant/widgets/dice_widget/dice_edit_dialog.dart';
import 'package:tabletop_assistant/widgets/dice_widget/dice_widget_data.dart';
import 'package:tabletop_assistant/widgets/editable.dart';
import 'package:tabletop_assistant/helpers.dart';

class DiceWidget extends StatefulWidget {
  final DiceWidgetData initData;

  const DiceWidget({super.key, required this.initData});

  @override
  State<StatefulWidget> createState() => DiceWidgetState();
}

class DiceWidgetState extends State<DiceWidget> implements Editable<DiceWidget> {
  static const decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow()],
  );

  final _random = Random();

  late DiceWidgetData _data;
  List<int>? _currentRoll;
  bool _isEditing = false;

  @override
  bool get isEditing => _isEditing;

  @override
  set isEditing(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }

  @override
  void initState() {
    _data = widget.initData;
    rollDice();
    super.initState();
  }

  int _randIntFrom1({required int to}) => _random.nextInt(to) + 1;

  void rollDice() async {
    setState(() {
      _currentRoll = null;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _currentRoll = List.generate(_data.numberOfDice, (_) => _randIntFrom1(to: _data.numberOfSides));
    });
  }

  void _showEditingDialog() {
    showDialog(
        context: context,
        builder: (context) => DiceEditDialog(
            data: _data,
            setData: (data) {
              setState(() {
                _data = data;
                rollDice();
              });
            }));
  }

  void _onTap() {
    if (_isEditing) {
      _showEditingDialog();
    } else if (!_data.longPressToReroll) {
      rollDice();
    }
  }

  void _onLongPress() {
    if (!_isEditing && _data.longPressToReroll) {
      rollDice();
    }
  }

  Widget _diceText(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displaySmall;
    final rollText = _currentRoll
      ?.map((element) => "$element")
      .reduce((value, element) => "$value+$element")
      .flatMap((value) => "$value=") ?? "";
    return FittedBox(
      fit: BoxFit.contain,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
        child: Text(
          rollText,
          style: textStyle,
        ),
      ),
    );
  }

  Widget _resultText(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.normal);
    final result = _currentRoll?.reduce((value, element) => value + element);
    return FittedBox(
      fit: BoxFit.contain,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
        child: Text(
          "${result ?? ""}",
          style: textStyle,
        ),
      ),
    );
  }

  Widget _titleWidget(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Text(_data.name, style: theme.headlineLarge);
  }

  Widget _rollWidget(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_data.numberOfDice > 1)
              Expanded(
                flex: 2,
                child: FractionallySizedBox(
                  heightFactor: 0.5,
                  child: Opacity(
                    opacity: 0.4,
                    child: _diceText(context),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: _resultText(context),
            )
          ]));

  Widget _configurationWidget(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final style = theme.headlineSmall?.copyWith(color: theme.headlineMedium?.color);
    final text = "${_data.numberOfSides}-sided";
    return Text(text, style: style);
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: decoration,
        height: 240,
        width: 240,
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _onTap,
          onLongPress: _onLongPress,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: _titleWidget(context),
              ),
              Expanded(
                flex: 3,
                child: _rollWidget(context),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: _configurationWidget(context),
              )
            ],
          ),
        ),
      );
}
