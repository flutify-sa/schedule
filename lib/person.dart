import 'package:schedule/task.dart';

class Person {
  String id;
  String name;
  String surname;
  List<Task> tasks;

  Person({
    required this.id,
    required this.name,
    required this.surname,
    List<Task>? tasks,
  }) : tasks = tasks ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'surname': surname,
    'tasks': tasks.map((task) => task.toJson()).toList(),
  };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'],
    name: json['name'],
    surname: json['surname'],
    tasks: (json['tasks'] as List?)?.map((task) => Task.fromJson(task)).toList() ?? [],
  );

  String get fullName => '$name $surname';
}