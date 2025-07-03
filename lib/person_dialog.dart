import 'package:flutter/material.dart';
import 'package:schedule/person.dart';


class PersonDialog extends StatefulWidget {
  final Person? person;
  final Function(Person) onSave;

  const PersonDialog({super.key, this.person, required this.onSave});

  @override
  PersonDialogState createState() => PersonDialogState();
}

class PersonDialogState extends State<PersonDialog> {
  late TextEditingController nameController;
  late TextEditingController surnameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.person?.name ?? '');
    surnameController = TextEditingController(text: widget.person?.surname ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.person == null ? 'Add Person' : 'Edit Person'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: surnameController,
            decoration: InputDecoration(labelText: 'Surname'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (nameController.text.isNotEmpty && surnameController.text.isNotEmpty) {
              final person = Person(
                id: widget.person?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                surname: surnameController.text,
                tasks: widget.person?.tasks ?? [],
              );
              widget.onSave(person);
              Navigator.pop(context);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
