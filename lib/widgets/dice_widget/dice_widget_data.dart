class DiceWidgetData {
  String name;
  int numberOfDice;
  int numberOfSides;
  bool longPressToReroll;

  DiceWidgetData({
    this.name = "",
    required this.numberOfDice, 
    required this.numberOfSides, 
    this.longPressToReroll = true
  });

  DiceWidgetData.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      numberOfDice = json['numberOfDice'],
      numberOfSides = json['numberOfSides'],
      longPressToReroll = json['longPressToReroll'] == 1;

  Map<String, dynamic> toJson() => {
    'name': name,
    'numberOfDice': numberOfDice,
    'numberOfSides': numberOfSides,
    'longPressToReroll': longPressToReroll ? 1 : 0
  };
}
