class TimerWidgetData {
  String name;
  int initialTime;

  TimerWidgetData({required this.name, required this.initialTime});

  TimerWidgetData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        initialTime = json['initialTime'];

  Map<String, dynamic> toJson() => {'name': name, 'initialTime': initialTime};
}
