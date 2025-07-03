// home_screen_methods.dart
import 'package:flutter/material.dart';
import 'package:schedule/data_service.dart';
import 'package:schedule/person.dart';
import 'package:schedule/person_dialog.dart';
import 'package:schedule/person_task_screen.dart';

mixin HomeScreenMethods<T extends StatefulWidget> on State<T> {
  List<Person> people = [];
  bool isLoading = true;

  Future<void> loadData() async {
    final loadedPeople = await DataService.loadPeople();
    setState(() {
      people = loadedPeople;
      isLoading = false;
    });
  }

  Future<void> saveData() async {
    await DataService.savePeople(people);
  }

  void addPerson(Person person) {
    setState(() {
      people.add(person);
    });
    saveData();
  }

  void updatePerson(Person updatedPerson) {
    setState(() {
      final index = people.indexWhere((p) => p.id == updatedPerson.id);
      if (index != -1) {
        people[index] = updatedPerson;
      }
    });
    saveData();
  }

  void deletePerson(String personId) {
    setState(() {
      people.removeWhere((p) => p.id == personId);
    });
    saveData();
  }

  void navigateToPersonTasks(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonTasksScreen(
          person: person,
          onPersonUpdated: updatePerson,
        ),
      ),
    );
  }

  void showPersonDialog({Person? person}) {
    showDialog(
      context: context,
      builder: (context) => PersonDialog(
        person: person,
        onSave: person == null ? addPerson : updatePerson,
      ),
    );
  }

  void showDeleteDialog(Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Person'),
        content: Text('Are you sure you want to delete ${person.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deletePerson(person.id);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
