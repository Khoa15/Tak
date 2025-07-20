import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tak/core/todo_provider.dart';
import 'package:tak/models/todo.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TodoProvider _todoProvider;

  @override
  void initState() {
    super.initState();
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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              widget.todo.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400
              ),
              softWrap: true,
            ),
            if (widget.todo.deadline != null)
              Text(
                'Hạn: ${widget.todo.deadline!.toLocal().toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[500],
                  fontWeight: FontWeight.w500
                ),
              ),
          ],
        ),
      ),
    );
  }
}
