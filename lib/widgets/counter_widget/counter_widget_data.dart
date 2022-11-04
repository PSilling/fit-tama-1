import 'dart:convert';

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

  CounterWidgetData.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      isUneven = json['isUneven'] == 1,
      scale = List<int>.from(jsonDecode(json['scale'])),
      defaultIndex = json['defaultIndex'],
      isLeftDeath = json['isLeftDeath'] == 1,
      isRightDeath = json['isRightDeath'] == 1;

  Map <String, dynamic> toJson() => {
    'name': name,
    'isUneven': isUneven ? 1 : 0,
    'scale': jsonEncode(scale),
    'defaultIndex': defaultIndex,
    'isLeftDeath': isLeftDeath ? 1 : 0,
    'isRightDeath': isRightDeath ? 1 : 0
  };
}
