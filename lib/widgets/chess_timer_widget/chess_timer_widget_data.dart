import 'dart:convert';

class ChessTimerWidgetData {
  String name;
  List<int> initialTimes;

  bool get isTogether => initialTimes
      .fold(true, (prev, elem) => prev && elem == initialTimes[0]);

  bool get isSeparate => !isTogether;

  ChessTimerWidgetData({required this.name, required this.initialTimes});

  ChessTimerWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        initialTimes = List<int>.from(jsonDecode(json['initialTime']));

  Map<String, dynamic> toJson() => {
    'name': name,
    'initialTime': jsonEncode(initialTimes)};
}
