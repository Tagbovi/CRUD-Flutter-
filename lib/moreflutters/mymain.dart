import 'package:flutter/material.dart';
import 'package:m/moreflutters/todopage.dart';

import 'package:m/services/todo_service.dart';

import '../utils/snackbar_helper.dart';
import '../widget/todo_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const ToDoListPage(),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchToDo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("trialsOnly")),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchToDo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'No Todo Item',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            child: ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final item = items[index] as Map;

                  return TodoCard(
                    index: index,
                    deleteById: deleteById,
                    navigateEdit: NavigateEditToDoPage,
                    item: item,
                  );
                }),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            NavigateAddToDoPage();
          },
          label: const Text('add todo')),
    );
  }

  // ignore: non_constant_identifier_names
  Future<void> NavigateAddToDoPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddToDoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  // ignore: non_constant_identifier_names
  Future<void> NavigateEditToDoPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  Future<void> deleteById(String id) async {
    final isSuccess = await TodoService.deleteById(id);

    //delete the item
    if (isSuccess) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
//remove item from list
    } else {
      // ignore: use_build_context_synchronously
      showErrorMessage(context, message: 'Deletion Failed');
      //show error
    }
  }

  Future<void> fetchToDo() async {
    final response = await TodoService().fetchTodos();
    if (response != null) {
      setState(() {
        items = response;
      });
    } else {
      // ignore: use_build_context_synchronously
      showErrorMessage(context, message: 'something went wrong');
    }
    setState(() {
      isLoading = false;
    });
    //
  }
}
