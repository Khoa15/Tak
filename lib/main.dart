import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class TodoItem {
  String text;
  DateTime? deadline;
  TodoItem(this.text, {this.deadline});
}

class _TodoPageState extends State<TodoPage> {
  final List<TodoItem> _todos = [];
  final TextEditingController _controller = TextEditingController();

  void _addTodo() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      DateTime? deadline = await _pickDeadline();
      setState(() {
        _todos.add(TodoItem(text, deadline: deadline));
        _controller.clear();
      });
    }
  }

  Future<DateTime?> _pickDeadline({DateTime? initialDate}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    return picked;
  }


  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _setDeadline(int index) async {
    DateTime? newDeadline = await _pickDeadline(initialDate: _todos[index].deadline);
    if (newDeadline != null) {
      setState(() {
        _todos[index].deadline = newDeadline;
      });
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
      setState(() {
        _todos[index].text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: Column(
        children: [
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
                return ListTile(
                  title: Text(todo.text),
                  subtitle: todo.deadline != null
                      ? Text('Deadline: 	${todo.deadline!.toLocal().toString().split(' ')[0]}')
                      : null,
                  onTap: () => _editTodo(index),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.event),
                        tooltip: 'Set deadline',
                        onPressed: () => _setDeadline(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editTodo(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTodo(index),
                      ),
                    ],
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
