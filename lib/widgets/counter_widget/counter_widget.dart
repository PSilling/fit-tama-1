import 'package:flutter/material.dart';
import 'package:tabletop_assistant/helpers.dart';
import 'package:tabletop_assistant/widgets/counter_widget/edit_dialog.dart';
import 'package:tabletop_assistant/widgets/counter_widget/reset_dialog.dart';
import 'package:tabletop_assistant/widgets/counter_widget/scale_dialog.dart';
import 'package:tabletop_assistant/widgets/editable.dart';

class CounterWidget extends StatefulWidget {
  static const death = Icon(Icons.sentiment_very_dissatisfied_rounded);

  final CounterWidgetData initData;
  const CounterWidget({super.key, required this.initData});

  @override
  State<CounterWidget> createState() => CounterWidgetState();
}

class CounterWidgetState extends State<CounterWidget>
    implements Editable<CounterWidget> {
  static const decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow()],
  );

  late CounterWidgetData data;
  late int currentIndex;
  var isEditing = false;

  @override
  bool getEditing() => isEditing;

  @override
  void setEditing(bool editing) {
    setState(() {
      isEditing = editing;
    });
  }

  @override
  void initState() {
    super.initState();
    data = widget.initData;
    currentIndex = data.defaultIndex;
  }

  void increaseIndex() {
    setState(() {
      final newIndex = currentIndex + 1;
      final deathModifier = data.isRightDeath ? 1 : 0;
      if (newIndex < data.scale.length + deathModifier) {
        currentIndex = newIndex;
      }
    });
  }

  void decreaseIndex() {
    setState(() {
      final newIndex = currentIndex - 1;
      final deathModifier = data.isLeftDeath ? 1 : 0;
      if (newIndex >= 0 - deathModifier) {
        currentIndex = newIndex;
      }
    });
  }

  void setIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void resetIndex() {
    setState(() {
      currentIndex = data.defaultIndex;
    });
  }

  void onLeftTapped() {
    if (isEditing) {
      showEditingDialog();
    } else {
      decreaseIndex();
    }
  }

  void onRightTapped() {
    if (isEditing) {
      showEditingDialog();
    } else {
      increaseIndex();
    }
  }

  void showResetIndexConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ResetDialog(
        originalValue: data.scale.elementAtOrNull(data.defaultIndex),
        resetIndex: resetIndex,
      ),
    );
  }

  void showScale() {
    showDialog(
      context: context,
      builder: (context) => ScaleDialog(
        scaleLength: data.scale.length,
        currentIndex: currentIndex,
        isLeftDeath: data.isLeftDeath,
        isRightDeath: data.isRightDeath,
        setCurrentIndex: setIndex,
        getNumberWidgetAt: getNumberWidgetAt,
      ),
    );
  }

  void showEditingDialog() {
    showDialog(
      context: context,
      builder: (context) => EditDialog(
        data: data,
        setData: (data) {
          setState(() {
            this.data = data;
            currentIndex = data.defaultIndex;
          });
        },
      ),
    );
  }

  Widget getNumberWidgetAt(int index,
      {TextAlign? textAlign, TextStyle? style}) {
    final number = data.scale.elementAtOrNull(index);
    if (number != null) {
      return Text("$number", textAlign: textAlign, style: style);
    } else {
      final leftDeath = data.isLeftDeath;
      final rightDeath = data.isRightDeath;
      if (leftDeath && index == -1) {
        return CounterWidget.death;
      } else if (rightDeath && index == data.scale.length) {
        return CounterWidget.death;
      } else {
        return Container();
      }
    }
  }

  Widget titleWidget(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return IgnorePointer(
        ignoring: isEditing,
        child: Text(
          data.name,
          style: theme.headlineLarge,
        ));
  }

  Widget numberButton(
      {required int index,
      required TextStyle? textStyle,
      required int flex,
      TextAlign? textAlign}) {
    return Expanded(
      flex: flex,
      child: IgnorePointer(
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Opacity(
            opacity: 0.4,
            child: FittedBox(
              fit: BoxFit.contain,
              child: getNumberWidgetAt(index,
                  textAlign: textAlign, style: textStyle),
            ),
          ),
        ),
      ),
    );
  }

  Widget numbersSection(BuildContext context) {
    final theme = Theme.of(context);
    final mainNumberStyle =
        theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.normal);
    final secondaryNumberStyle = theme.textTheme.displaySmall;
    return Expanded(
      child: Row(
        children: [
          numberButton(
            index: currentIndex - 1,
            flex: 4,
            textAlign: TextAlign.right,
            textStyle: secondaryNumberStyle,
          ),
          Expanded(
            flex: 5,
            child: IgnorePointer(
              ignoring: isEditing,
              child: GestureDetector(
                onTap: showScale,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 1, minHeight: 1),
                    child: getNumberWidgetAt(
                      currentIndex,
                      style: mainNumberStyle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          numberButton(
            index: currentIndex + 1,
            flex: 4,
            textAlign: TextAlign.left,
            textStyle: secondaryNumberStyle,
          ),
        ],
      ),
    );
  }

  Widget themedIcon(IconData? icon,
      {required BuildContext context, required String semanticLabel}) {
    final iconTheme = Theme.of(context).iconTheme;
    return Icon(
      icon,
      color: iconTheme.color,
      shadows: iconTheme.shadows,
      size: iconTheme.size,
      semanticLabel: semanticLabel,
    );
  }

  Widget buttonsSection(BuildContext context) {
    return Center(
      child: IgnorePointer(
        ignoring: isEditing,
        child: IconButton(
          onPressed: showResetIndexConfirmation,
          icon: themedIcon(Icons.replay,
              context: context, semanticLabel: "Reset the counter"),
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
                  onTap: onLeftTapped,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onRightTapped,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget(context),
              numbersSection(context),
              buttonsSection(context),
            ],
          ),
        ],
      ),
    );
  }
}

class CounterWidgetData {
  String name;
  bool isUneven;
  List<int> scale;
  int defaultIndex;
  bool isLeftDeath;
  bool isRightDeath;

  CounterWidgetData(
      {required this.name,
      required this.isUneven,
      required this.scale,
      required this.defaultIndex,
      required this.isLeftDeath,
      required this.isRightDeath});
}
