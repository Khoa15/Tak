import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tak/core/todo_provider.dart';
import 'package:tak/models/todo.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo todo;

  const TodoDetailScreen({Key? key, required this.todo}) : super(key: key);

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();

}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TodoProvider _todoProvider;

  @override
  void initState() {
    super.initState();
    // You can fetch the todo details using widget.todoId here
    // For example, you might want to call a method to fetch the todo details from a provider or service
    initialize();
  }

  void initialize() async {
    _todoProvider = TodoProvider();
    await _todoProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Text(
                widget.todo.text,
                style: TextStyle(fontSize: 24),
              ),
            SizedBox(width: 20),
            if (widget.todo.deadline != null)
                Text(
                  'Deadline: ${widget.todo.deadline!.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 18),
                ),
          ],
        ),
      ),
    );
  }
}