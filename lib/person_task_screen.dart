import 'package:flutter/material.dart';
import 'package:schedule/person.dart';
import 'package:schedule/task.dart';
import 'package:schedule/task_dialog.dart';


class PersonTasksScreen extends StatefulWidget {
  final Person person;
  final Function(Person) onPersonUpdated;

  const PersonTasksScreen({super.key, required this.person, required this.onPersonUpdated});

  @override
  PersonTasksScreenState createState() => PersonTasksScreenState();
}

class PersonTasksScreenState extends State<PersonTasksScreen> {
  late Person person;

  @override
  void initState() {
    super.initState();
    person = widget.person;
  }

  void addTask(Task task) {
    setState(() {
      person.tasks.add(task);
      person.tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
    widget.onPersonUpdated(person);
  }

  void updateTask(Task updatedTask) {
    setState(() {
      final index = person.tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        person.tasks[index] = updatedTask;
        person.tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
      }
    });
    widget.onPersonUpdated(person);
  }

  void deleteTask(String taskId) {
    setState(() {
      person.tasks.removeWhere((t) => t.id == taskId);
    });
    widget.onPersonUpdated(person);
  }

  bool hasTimeConflict(Task newTask, {String? excludeTaskId}) {
    for (Task existingTask in person.tasks) {
      if (excludeTaskId != null && existingTask.id == excludeTaskId) continue;
      
      if (newTask.startTime.isBefore(existingTask.endTime) && 
          newTask.endTime.isAfter(existingTask.startTime)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${person.fullName} - Tasks'),
        backgroundColor: Colors.blue,
      ),
      body: person.tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tasks scheduled',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: person.tasks.length,
              itemBuilder: (context, index) {
                final task = person.tasks[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.task, color: Colors.blue),
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start: ${_formatDateTime(task.startTime)}'),
                        Text('End: ${_formatDateTime(task.endTime)}'),
                        Text('Duration: ${task.durationString}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showTaskDialog(task: task);
                        } else if (value == 'delete') {
                          _showDeleteTaskDialog(task);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showTaskDialog({Task? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        onSave: (newTask) {
          if (hasTimeConflict(newTask, excludeTaskId: task?.id)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Time conflict with existing task!'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          if (task == null) {
            addTask(newTask);
          } else {
            updateTask(newTask);
          }
        },
      ),
    );
  }

  void _showDeleteTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteTask(task.id);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
