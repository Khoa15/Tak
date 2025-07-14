import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoDetailScreen extends StatefulWidget {
  final String todoId;

  const TodoDetailScreen({Key? key, required this.todoId}) : super(key: key);

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();

}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Details for Todo ID: ${widget.todoId}'),
      ),
    );
  }
}