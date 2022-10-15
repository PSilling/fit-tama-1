class DiceWidgetData {
  String name;
  int numberOfDice;
  int numberOfSides;
  bool longPressToReroll;

  DiceWidgetData(
      {this.name = "",
      required this.numberOfDice,
      required this.numberOfSides,
      this.longPressToReroll = true});
}
