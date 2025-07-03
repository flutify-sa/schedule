import 'package:flutter/material.dart';
import 'package:schedule/data_service.dart';
import 'package:schedule/person.dart';
import 'package:schedule/person_dialog.dart';
import 'package:schedule/person_task_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Person> people = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(backgroundColor: Colors.blue.shade50,
      appBar: AppBar(foregroundColor: Colors.white,
        title: Text('Schedule Manager'),
        backgroundColor: Colors.purple.shade900,
      ),
      body: people.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No people added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(person.name[0].toUpperCase()),
                    ),
                    title: Text(person.fullName),
                    subtitle: Text('${person.tasks.length} tasks'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showPersonDialog(person: person);
                        } else if (value == 'delete') {
                          _showDeleteDialog(person);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () => _navigateToPersonTasks(person),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPersonDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToPersonTasks(Person person) {
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

  void _showPersonDialog({Person? person}) {
    showDialog(
      context: context,
      builder: (context) => PersonDialog(
        person: person,
        onSave: person == null ? addPerson : updatePerson,
      ),
    );
  }

  void _showDeleteDialog(Person person) {
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
