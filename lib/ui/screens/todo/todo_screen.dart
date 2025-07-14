import 'package:flutter/material.dart';
import 'package:tak/core/TodoProvider.dart';
import 'package:tak/models/todo.dart';
import 'package:tak/utils/notification_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  late TodoProvider _todoProvider;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    NotificationService().isAndroidPermissionGranted();
    NotificationService().requestPermissions();
    _todoProvider = TodoProvider();
    await _todoProvider.init();
    _todoProvider.getAllTodos().then((todos) {
      setState(() {
        _todos.addAll(todos);
      });
    }).catchError((error) {
      // Handle error if needed
      print('Error fetching todos: $error');
    });
    // notificationService().requestPermissions();
  }





  void _addTodo() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      DateTime? deadline = await _pickDeadline();
      if (deadline == null) {
        // If the deadline is in the past, show an error
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Deadline cannot be in the past')),
        // );
        return;
      }
      _todoProvider.insert(Todo(text: text, deadline: deadline)).then((todo) {
        setState(() {
          _todos.add(todo);
          _controller.clear();
        });
        NotificationService().scheduleDailyNotification(
          id: todo.id!,
          body: 'Todo: $text' + (deadline != null ? ' by ${deadline.toLocal().toString().split(' ')[0]}' : ''),
          scheduledDateTime: deadline ?? DateTime.now().add(const Duration(days: 1, hours: 6)),
        );
      }).catchError((error) {
        // Handle error if needed
        print('Error adding todo: $error');
      });
    }
  }

  Future<DateTime?> _pickDeadline({DateTime? initialDate}) async {
    final now = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    return picked;
  }


  void _removeTodo(int index) {
    _todoProvider.delete(_todos[index].id!).then((_) {
      NotificationService().cancelNotification(_todos[index].id!);
      setState(() {
        _todos.removeAt(index);
      });
    }).catchError((error) {
      // Handle error if needed
      print('Error removing todo: $error');
    });
    
  }

  void _setDeadline(int index) async {
    DateTime? newDeadline = await _pickDeadline(initialDate: _todos[index].deadline);
    if (newDeadline != null) {
      setState(() {
        _todos[index].deadline = newDeadline;
      });
      NotificationService().scheduleDailyNotification(
        id: _todos[index].id!,
        body: 'Todo: ${_todos[index].text} by ${newDeadline.toLocal().toString().split(' ')[0]}',
        scheduledDateTime: newDeadline,
      );
    }
  }

  void _editTodo(int index) async {
    final TextEditingController editController = TextEditingController(text: _todos[index].text);
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
            onPressed: () => Navigator.of(context).pop(editController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      _todoProvider.update(Todo(id: _todos[index].id, text: result, deadline: _todos[index].deadline)).then((_) {
        // Update the todo in the list
        setState(() {
          _todos[index].text = result;
        });
        NotificationService().scheduleDailyNotification(
          id: _todos[index].id!,
          body: 'Todo: ${_todos[index].text}' + (_todos[index].deadline != null ? ' by ${_todos[index].deadline!.toLocal().toString().split(' ')[0]}' : ''),
          scheduledDateTime: _todos[index].deadline ?? DateTime.now().add(const Duration(days: 1, hours: 6)),
        );
      }).catchError((error) {
        // Handle error if needed
        print('Error updating todo: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tak')),
      body: Column(
        children: [
          // ElevatedButton(
          //   onPressed: () async {
          //     await NotificationService().showNotification(
          //       body: 'All todos cleared',
          //     );
          //   },
          //   child: const Text('Show Notification'),
          // ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Add a todo',
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Dismissible(
                  key: Key(todo.id.toString()),
                  onDismissed: (direction) {
                    _removeTodo(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${todo.text.length>=10?'${todo.text.substring(0, 10)}...':todo.text} is deleted')),
                    );
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(todo.text),
                    subtitle: todo.deadline != null
                        ? Text('Deadline: ${todo.deadline!.toLocal().toString().split(' ')[0]}')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTodo(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _setDeadline(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}