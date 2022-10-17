import 'package:flutter/material.dart';
import 'package:tabletop_assistant/helpers.dart';
import 'package:tabletop_assistant/widgets/counter_widget/counter_widget_data.dart';
import 'package:tabletop_assistant/widgets/counter_widget/dialogs/counter_edit_dialog.dart';
import 'package:tabletop_assistant/widgets/counter_widget/dialogs/counter_reset_dialog.dart';
import 'package:tabletop_assistant/widgets/counter_widget/dialogs/counter_scale_dialog.dart';
import 'package:tabletop_assistant/widgets/editable.dart';

class CounterWidget extends StatefulWidget {
  static const _death = Icons.sentiment_very_dissatisfied_rounded;

  final CounterWidgetData initData;
  const CounterWidget({super.key, required this.initData});

  @override
  State<CounterWidget> createState() => CounterWidgetState();
}

class CounterWidgetState extends State<CounterWidget> implements Editable<CounterWidget> {
  static const decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow()],
  );

  late CounterWidgetData _data;
  late int _currentIndex;
  var _isEditing = false;

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

  Widget _getNumberWidgetAt(int index, {TextAlign? textAlign, TextStyle? style}) {
    final number = _data.scale.elementAtOrNull(index);
    if (number != null) {
      return Text("$number", textAlign: textAlign, style: style);
    } else {
      final leftDeath = _data.isLeftDeath;
      final rightDeath = _data.isRightDeath;
      final deathIcon = _themedIcon(CounterWidget._death, context: context, semanticLabel: "Death");
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
    final theme = Theme.of(context).textTheme;
    return IgnorePointer(
      ignoring: _isEditing,
      child: Text(
        _data.name,
        style: theme.headlineLarge,
      ),
    );
  }

  Widget _numberButton({required int index, required TextStyle? textStyle, required int flex, TextAlign? textAlign}) {
    return Expanded(
      flex: flex,
      child: IgnorePointer(
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Opacity(
            opacity: 0.4,
            child: FittedBox(
              fit: BoxFit.contain,
              child: _getNumberWidgetAt(index, textAlign: textAlign, style: textStyle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numbersSection(BuildContext context) {
    final theme = Theme.of(context);
    final mainNumberStyle = theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.normal);
    final secondaryNumberStyle = theme.textTheme.displaySmall;
    return Row(
      children: [
        _numberButton(
          index: _currentIndex - 1,
          flex: 4,
          textAlign: TextAlign.right,
          textStyle: secondaryNumberStyle,
        ),
        Expanded(
          flex: 5,
          child: IgnorePointer(
            ignoring: _isEditing,
            child: GestureDetector(
              onTap: _showScale,
              child: FittedBox(
                fit: BoxFit.contain,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
                  child: _getNumberWidgetAt(
                    _currentIndex,
                    style: mainNumberStyle,
                  ),
                ),
              ),
            ),
          ),
        ),
        _numberButton(
          index: _currentIndex + 1,
          flex: 4,
          textAlign: TextAlign.left,
          textStyle: secondaryNumberStyle,
        ),
      ],
    );
  }

  Widget _themedIcon(IconData? icon, {required BuildContext context, required String semanticLabel}) {
    final iconTheme = Theme.of(context).iconTheme;
    final textTheme = Theme.of(context).textTheme;
    return Icon(
      icon,
      color: textTheme.displayLarge?.color,
      shadows: iconTheme.shadows,
      size: iconTheme.size,
      semanticLabel: semanticLabel,
    );
  }

  Widget _buttonsSection(BuildContext context) {
    return Center(
      child: IgnorePointer(
        ignoring: _isEditing,
        child: IconButton(
          onPressed: _showResetIndexConfirmation,
          icon: _themedIcon(Icons.replay, context: context, semanticLabel: "Reset the counter"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      height: 240,
      width: 240,
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onLeftTapped,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onRightTapped,
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
