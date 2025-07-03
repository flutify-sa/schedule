
class Task {
  String id;
  String title;
  DateTime startTime;
  DateTime endTime;

  Task({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);

  String get durationString {
    final duration = this.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
  );
}