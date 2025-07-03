
import 'dart:convert';

import 'package:schedule/person.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static const String _peopleKey = 'people_data';

  static Future<List<Person>> loadPeople() async {
    final prefs = await SharedPreferences.getInstance();
    final String? peopleJson = prefs.getString(_peopleKey);
    
    if (peopleJson == null) return [];
    
    final List<dynamic> peopleList = jsonDecode(peopleJson);
    return peopleList.map((json) => Person.fromJson(json)).toList();
  }

  static Future<void> savePeople(List<Person> people) async {
    final prefs = await SharedPreferences.getInstance();
    final String peopleJson = jsonEncode(people.map((person) => person.toJson()).toList());
    await prefs.setString(_peopleKey, peopleJson);
  }
}