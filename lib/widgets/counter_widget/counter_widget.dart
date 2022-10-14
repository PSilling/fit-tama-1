import 'package:flutter/material.dart';
import 'package:tabletop_assistant/helpers.dart';
import 'package:tabletop_assistant/widgets/counter_widget/reset_dialog.dart';
import 'package:tabletop_assistant/widgets/counter_widget/scale_dialog.dart';

class CounterWidget extends StatefulWidget {
  final name = "Threat";
  final scale = const [3, 3, 3, 4, 5, 6, 6, 99, 105, 105, 106];
  final defaultIndex = 3;
  final isLeftDeath = true;
  final isRightDeath = false;

  static const death = Icon(Icons.sentiment_very_dissatisfied_rounded);

  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => CounterWidgetState();
}

class CounterWidgetState extends State<CounterWidget> {
  static const decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow()],
  );

  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.defaultIndex;
    super.initState();
  }

  void increaseIndex() {
    setState(() {
      final newIndex = currentIndex + 1;
      final deathModifier = widget.isRightDeath ? 1 : 0;
      if (newIndex < widget.scale.length + deathModifier) {
        currentIndex = newIndex;
      }
    });
  }

  void decreaseIndex() {
    setState(() {
      final newIndex = currentIndex - 1;
      final deathModifier = widget.isLeftDeath ? 1 : 0;
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
      currentIndex = widget.defaultIndex;
    });
  }

  void showResetIndexConfirmation() {
    showDialog(
        context: context,
        builder: (context) {
          final originalValue =
              widget.scale.elementAtOrNull(widget.defaultIndex);
          return ResetDialog(
            originalValue: originalValue,
            resetIndex: resetIndex,
          );
        });
  }

  void showScale() {
    showDialog(
        context: context,
        builder: (context) {
          return ScaleDialog(
            scaleLength: widget.scale.length,
            currentIndex: currentIndex,
            isLeftDeath: widget.isLeftDeath,
            isRightDeath: widget.isRightDeath,
            setCurrentIndex: setIndex,
            getNumberWidgetAt: getNumberWidgetAt,
          );
        });
  }

  Widget getNumberWidgetAt(int index, {TextAlign? textAlign, TextStyle? style}) {
    final number = widget.scale.elementAtOrNull(index);
    if (number != null) {
      return Text("$number", textAlign: textAlign, style: style);
    } else {
      final leftDeath = widget.isLeftDeath;
      final rightDeath = widget.isRightDeath;
      if (leftDeath && index == -1) {
        return CounterWidget.death;
      } else if (rightDeath && index == widget.scale.length) {
        return CounterWidget.death;
      } else {
        return Container();
      }
    }
  }

  Widget titleWidget(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Text(
      widget.name,
      style: theme.headlineLarge,
    );
  }

  Widget numberButton(
      {required int index,
      void Function()? onPressed,
      void Function()? onLongPressed,
      required TextStyle? textStyle,
      required int flex,
      TextAlign? textAlign}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onPressed,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Opacity(
            opacity: 0.4,
            child: FittedBox(
              fit: BoxFit.contain,
              child: getNumberWidgetAt(index, textAlign: textAlign, style: textStyle),
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
            onPressed: decreaseIndex,
            textStyle: secondaryNumberStyle,
          ),
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: showScale,
              child: FittedBox(
                fit: BoxFit.contain,
                child: getNumberWidgetAt(
                  currentIndex,
                  style: mainNumberStyle,
                ),
              ),
            ),
          ),
          numberButton(
            index: currentIndex + 1,
            flex: 4,
            textAlign: TextAlign.left,
            onPressed: increaseIndex,
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
      child: IconButton(
        onPressed: showResetIndexConfirmation,
        icon: themedIcon(Icons.replay,
            context: context, semanticLabel: "Reset the counter"),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          titleWidget(context),
          numbersSection(context),
          buttonsSection(context),
        ],
      ),
    );
  }
}
