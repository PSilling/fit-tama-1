import 'dart:math';

import 'package:board_aid/themes.dart';
import 'package:flutter/material.dart';

import '../../helpers/measure_size.dart';
import './counter_widget_data.dart';
import './dialogs/counter_edit_dialog.dart';
import './dialogs/counter_reset_dialog.dart';
import './dialogs/counter_scale_dialog.dart';
import '../../helpers/extensions.dart';
import '../editable.dart';

class CounterWidget extends StatefulWidget {
  static const _death = Icons.sentiment_very_dissatisfied_rounded;

  final CounterWidgetData initData;
  const CounterWidget({super.key, required this.initData});

  @override
  State<CounterWidget> createState() => CounterWidgetState();
}

class CounterWidgetState extends State<CounterWidget> implements Editable<CounterWidget> {
  late CounterWidgetData _data;
  late int _currentIndex;
  var _isEditing = false;

  _PanDirection? _panDirection;
  final _numbersHeight = ValueNotifier<double?>(null);

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
    super.initState();
    _data = widget.initData;
    _currentIndex = _data.defaultIndex;
  }

  CounterWidgetData get data => _data;

  void increaseIndex() {
    setState(() {
      final newIndex = _currentIndex + 1;
      final deathModifier = _data.isRightDeath ? 1 : 0;
      if (newIndex < _data.scale.length + deathModifier) {
        _currentIndex = newIndex;
      }
    });
  }

  void decreaseIndex() {
    setState(() {
      final newIndex = _currentIndex - 1;
      final deathModifier = _data.isLeftDeath ? 1 : 0;
      if (newIndex >= 0 - deathModifier) {
        _currentIndex = newIndex;
      }
    });
  }

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void resetIndex() {
    setState(() {
      _currentIndex = _data.defaultIndex;
    });
  }

  void _onLeftTapped() {
    if (_isEditing) {
      _showEditingDialog();
    } else {
      decreaseIndex();
    }
  }

  void _onRightTapped() {
    if (_isEditing) {
      _showEditingDialog();
    } else {
      increaseIndex();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isEditing || _panDirection == null) {
      return;
    }

    switch (_panDirection!) {
      case _PanDirection.left:
        increaseIndex();
        break;
      case _PanDirection.right:
        decreaseIndex();
        break;
      case _PanDirection.none:
        break;
    }
    _panDirection = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isEditing || _panDirection != null) {
      return;
    }
    if (details.delta.dx.abs() > details.delta.dy.abs()) {
      if (details.delta.dx < 0) {
        _panDirection = _PanDirection.left;
      } else {
        _panDirection = _PanDirection.right;
      }
    } else {
      _panDirection = _PanDirection.none;
    }
  }

  void _onPanCancel() {
    _panDirection = null;
  }

  void _showResetIndexConfirmation() {
    showDialog(
      context: context,
      builder: (context) => CounterResetDialog(
        originalValue: _data.scale.elementAtOrNull(_data.defaultIndex),
        resetIndex: resetIndex,
      ),
    );
  }

  void _showScale() {
    showDialog(
      context: context,
      builder: (context) => CounterScaleDialog(
        scaleLength: _data.scale.length,
        currentIndex: _currentIndex,
        defaultIndex: _data.defaultIndex,
        isLeftDeath: _data.isLeftDeath,
        isRightDeath: _data.isRightDeath,
        setCurrentIndex: setIndex,
        getNumberWidgetAt: _getNumberWidgetAt,
      ),
    );
  }

  void _showEditingDialog() {
    showDialog(
      context: context,
      builder: (context) => CounterEditDialog(
        data: _data,
        setData: (data) {
          setState(() {
            _data = data;
            _currentIndex = data.defaultIndex;
          });
        },
      ),
    );
  }

  Widget _getNumberWidgetAt(int index, {TextStyle? style}) {
    final number = _data.scale.elementAtOrNull(index);
    if (number != null) {
      return Text("$number", style: style);
    } else {
      final leftDeath = _data.isLeftDeath;
      final rightDeath = _data.isRightDeath;
      final deathIcon = _themedIcon(CounterWidget._death, context: context, semanticLabel: "Death", style: style);
      if (leftDeath && index == -1) {
        return deathIcon;
      } else if (rightDeath && index == _data.scale.length) {
        return deathIcon;
      } else {
        return Container();
      }
    }
  }

  Widget _titleWidget(BuildContext context) {
    return IgnorePointer(
      ignoring: _isEditing,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          _data.name,
          style: ThemeHelper.widgetTitle(context),
        ),
      ),
    );
  }

  // Has size of widest displayed number, to keep the number positioning/size even
  Widget _sizer({required TextStyle? style}) {
    final center = _data.scale.elementAtOrNull(_currentIndex);
    final numberOfDigits = center?.toString().length ??
        [-1, 1]
            .compactMap((element) => _data.scale.elementAtOrNull(_currentIndex + element))
            .map((element) => element.toString().length)
            .reduce(max);
    final ems = List.filled(max(numberOfDigits, 1), "4").join(); // 4 is the widest number
    return Text(
      ems,
      style: style?.copyWith(color: Colors.transparent),
    );
  }

  Widget _fittingNumber({required int index, required TextStyle? textStyle, required AlignmentGeometry alignment}) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Stack(
        alignment: alignment,
        children: [
          _getNumberWidgetAt(index, style: textStyle),
          _sizer(style: textStyle),
        ],
      ),
    );
  }

  Widget _numberButton(
      {required int index, required TextStyle? textStyle, required int flex, required AlignmentGeometry alignment}) {
    return Expanded(
      flex: flex,
      child: ValueListenableBuilder<double?>(
          valueListenable: _numbersHeight,
          builder: (context, height, child) {
            if (height == null) {
              return const SizedBox.expand();
            }
            return SizedBox(
              height: height * 0.6,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.4,
                  child: _fittingNumber(index: index, textStyle: textStyle, alignment: alignment),
                ),
              ),
            );
          }),
    );
  }

  Widget _numbersSection(BuildContext context) {
    return Row(
      children: [
        _numberButton(
          index: _currentIndex - 1,
          flex: 4,
          alignment: Alignment.centerRight,
          textStyle: ThemeHelper.widgetContentSecondary(context),
        ),
        Expanded(
          flex: 5,
          child: MeasureSize(
            onChange: (size) => _numbersHeight.value = size.height,
            child: IgnorePointer(
              ignoring: _isEditing,
              child: GestureDetector(
                onTap: _showScale,
                onPanEnd: _onPanEnd,
                onPanUpdate: _onPanUpdate,
                onPanCancel: _onPanCancel,
                child: _fittingNumber(
                  index: _currentIndex,
                  textStyle: ThemeHelper.widgetContentMain(context),
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ),
        _numberButton(
          index: _currentIndex + 1,
          flex: 4,
          alignment: Alignment.centerLeft,
          textStyle: ThemeHelper.widgetContentSecondary(context),
        ),
      ],
    );
  }

  Widget _themedIcon(IconData? icon, {required BuildContext context, required String semanticLabel, TextStyle? style}) =>
      Icon(icon, semanticLabel: semanticLabel, color: style?.color);

  Widget _buttonsSection(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: IgnorePointer(
        ignoring: _isEditing,
        child: IconButton(
          onPressed: _showResetIndexConfirmation,
          icon: _themedIcon(
            Icons.replay,
            context: context,
            semanticLabel: "Reset the counter",
            style: ThemeHelper.widgetTitleBottom(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeHelper.widgetBackgroundColor(context),
        borderRadius: BorderRadius.all(Radius.circular(ThemeHelper.borderRadius())),
        boxShadow: const [BoxShadow()],
      ),
      padding: ThemeHelper.cardPadding(),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onLeftTapped,
                  onPanEnd: _onPanEnd,
                  onPanUpdate: _onPanUpdate,
                  onPanCancel: _onPanCancel,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onRightTapped,
                  onPanEnd: _onPanEnd,
                  onPanUpdate: _onPanUpdate,
                  onPanCancel: _onPanCancel,
                ),
              ),
            ],
          ),
          Column(
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
                child: _numbersSection(context),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: _buttonsSection(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _PanDirection { left, right, none }
