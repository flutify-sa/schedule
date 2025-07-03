import 'package:flutter/material.dart';
import 'package:schedule/task.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskDialog({super.key, this.task, required this.onSave});

  @override
  TaskDialogState createState() => TaskDialogState();
}

class TaskDialogState extends State<TaskDialog> {
  late TextEditingController titleController;
  late DateTime startTime;
  late DateTime endTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? '');
    startTime = widget.task?.startTime ?? DateTime.now();
    endTime = widget.task?.endTime ?? DateTime.now().add(Duration(hours: 1));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Start Time'),
              subtitle: Text(_formatDateTime(startTime)),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectDateTime(startTime, (dateTime) {
                setState(() {
                  startTime = dateTime;
                  if (endTime.isBefore(startTime)) {
                    endTime = startTime.add(Duration(hours: 1));
                  }
                });
              }),
            ),
            ListTile(
              title: Text('End Time'),
              subtitle: Text(_formatDateTime(endTime)),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectDateTime(endTime, (dateTime) {
                setState(() {
                  endTime = dateTime;
                });
              }),
            ),
            SizedBox(height: 8),
            Text(
              'Duration: ${endTime.difference(startTime).inHours}h ${endTime.difference(startTime).inMinutes % 60}m',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isNotEmpty && endTime.isAfter(startTime)) {
              final task = Task(
                id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                startTime: startTime,
                endTime: endTime,
              );
              widget.onSave(task);
              Navigator.pop(context);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateTime(
    DateTime initialDateTime,
    Function(DateTime) onDateTimeSelected,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted) return; // Check if widget is still mounted

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
      );

      if (!mounted) return; // Check again after await

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDateTimeSelected(newDateTime);
      }
    }
  }
}
