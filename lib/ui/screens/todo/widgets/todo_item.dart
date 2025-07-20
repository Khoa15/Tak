import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tak/core/todo_provider.dart';
import 'package:tak/models/todo.dart';
import 'package:tak/ui/screens/todo/todo_detail_screen.dart';
import 'package:tak/utils/notification_service.dart';
import 'package:tak/utils/time.dart';

class TodoItem extends StatefulWidget {
  const TodoItem({super.key, required this.todo, required this.todoProvider});
  final Todo todo;
  final TodoProvider todoProvider;

  @override
  State<StatefulWidget> createState() {
    return _TodoItemState();
  }
}

class _TodoItemState extends State<TodoItem> {
  late final TodoProvider _todoProvider = widget.todoProvider;
  late final Todo _todo = widget.todo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _todo.isDone,
            onChanged: (bool? value) {
              if (value != null) {
                _markAsDone(value);
              }
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoDetailScreen(todo: _todo),
                  ),
                ),
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _todo.text,
                    style: TextStyle(
                      color: _todo.isDone ? Colors.grey[400] : Colors.black,
                      decoration: _todo.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                  Text(
                    _todo.deadline!.toLocal().toString().split(' ')[0],
                    style: TextStyle(
                      color: _todo.isDone ? Colors.grey[400] : Colors.black87,
                      fontSize: 13
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editTodo(),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _setDeadline(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editTodo() async {
    final TextEditingController editController = TextEditingController(
      text: _todo.text,
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Todo'),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(editController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      _todoProvider
          .update(Todo(id: _todo.id, text: result, deadline: _todo.deadline))
          .then((_) {
            // Update the todo in the list
            setState(() {
              _todo.text = result;
            });
            NotificationService().scheduleDailyNotification(
              id: _todo.id!,
              body:
                  'Todo: ${_todo.text}' +
                  (_todo.deadline != null
                      ? ' by ${_todo.deadline!.toLocal().toString().split(' ')[0]}'
                      : ''),
              scheduledDateTime:
                  _todo.deadline ??
                  DateTime.now().add(const Duration(days: 1, hours: 6)),
            );
          })
          .catchError((error) {
            // Handle error if needed
            print('Error updating todo: $error');
          });
    }
  }

  void _setDeadline(BuildContext context) async {
    DateTime? newDeadline = await Time.pickDeadline(
      context: context,
      initialDate: _todo.deadline,
    );
    if (newDeadline != null) {
      setState(() {
        _todo.deadline = newDeadline;
      });
      NotificationService().scheduleDailyNotification(
        id: _todo.id!,
        body:
            'Todo: ${_todo.text} by ${newDeadline.toLocal().toString().split(' ')[0]}',
        scheduledDateTime: newDeadline,
      );
    }
  }

  void _markAsDone(bool isDone) {
    _todoProvider
        .markTodoAsDone(_todo.id!, isDone)
        .then((_) {
          NotificationService().cancelNotification(_todo.id!);
          if (isDone == false) {
            if (_todo.deadline!.compareTo(DateTime.now()) > 0) {
              NotificationService().scheduleDailyNotification(
                id: _todo.id!,
                body:
                    'Todo: ${_todo.text} by ${_todo.deadline.toString().split(' ')[0]}',
                scheduledDateTime:
                    _todo.deadline ??
                    DateTime.now().add(const Duration(days: 1, hours: 6)),
              );
            }
          }
          setState(() {
            _todo.isDone = isDone;
          });
          if (isDone) {
            NotificationService().cancelNotification(_todo.id!);
          }
        })
        .catchError((error) {
          // Handle error if needed
          print('Error marking todo as done: $error');
        });
  }
}
