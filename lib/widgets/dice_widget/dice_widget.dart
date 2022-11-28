import 'dart:math';

import 'package:board_aid/util/measure_size.dart';
import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';

import '../../util/extensions.dart';
import '../../views/edit_views/edit_dice_widget_view.dart';
import '../editable.dart';
import 'dice_widget_data.dart';

class DiceWidget extends StatefulWidget {
  final DiceWidgetData initData;
  final bool startEditing;

  const DiceWidget({
    super.key,
    required this.initData,
    required this.startEditing,
  });

  @override
  State<StatefulWidget> createState() => DiceWidgetState();
}

class DiceWidgetState extends State<DiceWidget>
    implements Editable<DiceWidget> {
  final _random = Random();

  late DiceWidgetData _data;
  List<int>? _currentRoll;
  bool _isEditing = false;

  final _resultHeight = ValueNotifier<double?>(null);

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
    _isEditing = widget.startEditing;
    _data = widget.initData;
    rollDice();
    super.initState();
  }

  DiceWidgetData get data => _data;

  int _randIntFrom1({required int to}) => _random.nextInt(to) + 1;

  void rollDice() async {
    setState(() {
      _currentRoll = null;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _currentRoll = List.generate(
          _data.numberOfDice, (_) => _randIntFrom1(to: _data.numberOfSides));
    });
  }

  void _openEditView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDiceWidgetView(
          data: _data,
          setData: (data) {
            setState(() {
              _data = data;
              rollDice();
            });
          },
        ),
      ),
    );
  }

  void _onTap() {
    if (_isEditing) {
      _openEditView();
    } else if (!_data.longPressToReroll) {
      rollDice();
    }
  }

  void _onLongPress() {
    if (!_isEditing && _data.longPressToReroll) {
      rollDice();
    }
  }

  bool _showDiceTextCondition() {
    return _data.numberOfDice > 1 &&
        _data.numberOfSides.toString().length * _data.numberOfDice <= 3;
  }

  Widget _diceText(BuildContext context) {
    final rollText = _currentRoll
            ?.map((element) => "$element")
            .reduce((value, element) => "$value+$element")
            .flatMap((value) => "$value=") ??
        "";
    return ValueListenableBuilder(
      valueListenable: _resultHeight,
      builder: (context, height, child) {
        if (height == null) {
          return const SizedBox.expand();
        }
        return SizedBox(
          height: height * 0.6,
          child: FittedBox(
            fit: BoxFit.contain,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 1, minWidth: 1),
              child: Text(
                rollText,
                textAlign: TextAlign.right,
                style: ThemeHelper.widgetContentSecondary(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _resultText(BuildContext context) {
    final result = _currentRoll?.reduce((value, element) => value + element);
    return MeasureSize(
      onChange: (size) => _resultHeight.value = size.height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
          child: Text(
            "${result ?? ""}",
            textAlign:
                _showDiceTextCondition() ? TextAlign.left : TextAlign.center,
            style: ThemeHelper.widgetContentMain(context),
          ),
        ),
      ),
    );
  }

  Widget _titleWidget(BuildContext context) => FittedBox(
        fit: BoxFit.contain,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 1, minWidth: 1),
          child: Text(
            _data.name,
            style: ThemeHelper.widgetTitle(context),
          ),
        ),
      );

  Widget _rollWidget(BuildContext context) => FractionallySizedBox(
        heightFactor: 0.7,
        child: Padding(
          padding: _showDiceTextCondition()
              ? const EdgeInsets.only(right: 10)
              : EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showDiceTextCondition())
                Flexible(
                  flex: 3,
                  child: Opacity(
                    opacity: 0.4,
                    child: _diceText(context),
                  ),
                ),
              Flexible(
                flex: 2,
                child: _resultText(context),
              )
            ],
          ),
        ),
      );

  Widget _configurationWidget(BuildContext context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            "${_data.numberOfSides}-sided",
            style: ThemeHelper.widgetTitleBottom(context),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color:
              _data.backgroundColor ?? ThemeHelper.cardBackgroundColor(context),
          borderRadius:
              BorderRadius.all(Radius.circular(ThemeHelper.borderRadius())),
          boxShadow: const [BoxShadow()],
        ),
        padding: ThemeHelper.cardPadding(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _onTap,
          onLongPress: _isEditing ? null : _onLongPress,
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
