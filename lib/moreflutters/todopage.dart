import 'package:flutter/material.dart';

import 'package:m/services/todo_service.dart';

import '../utils/snackbar_helper.dart';

class AddToDoPage extends StatefulWidget {
  final Map? todo;
  const AddToDoPage({super.key, this.todo});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? 'Edit TODO' : 'ADD TODO',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
              keyboardType: TextInputType.multiline,
              minLines: 8,
              maxLines: 16,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                isEdit ? updateData() : submitData();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(isEdit ? 'Update' : 'Submit'),
              ),
            ),
          ],
        ));
  }

//update function
  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      // ignore: avoid_print
      print('you cannot call updated todo');
      return;
    }
    final id = todo['_id'];

    // update submitted data to server
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final isSuccess = await TodoService.updateTodo(id, body);

    if (isSuccess) {
      titleController.text = " ";
      descriptionController.text = " ";
      // ignore: use_build_context_synchronously
      showSucessMessage(context, message: "Updation Success");
    } else {
      // ignore: use_build_context_synchronously
      showErrorMessage(context, message: "Updation Failed");
    }
  }

//SubmitData function
  Future<void> submitData() async {
    //Get the data from form
    //submit data to server
    const url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final isSuccess = await TodoService.addTodo(body); //am here

    //show success or fail message
    if (isSuccess) {
      titleController.text = " ";
      descriptionController.text = " ";
      // ignore: use_build_context_synchronously
      showSucessMessage(context, message: "creation Success");
    } else {
      // ignore: use_build_context_synchronously
      showErrorMessage(context, message: "creation Failed");
    }
  }

  Map get body {
    final title = titleController.text;
    final description = descriptionController.text;
    return {
      "title": title,
      "description": description,
      "is_completed": false,
    };
  }
}
