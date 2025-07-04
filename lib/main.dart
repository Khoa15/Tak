import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap (optional)
    },
  );
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
  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _addTodo() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      DateTime? deadline = await _pickDeadline();
      setState(() {
        _todos.add(TodoItem(text, deadline: deadline));
        _controller.clear();
      });
      _scheduleDailyNotification();
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
    _scheduleDailyNotification();
  }

  void _setDeadline(int index) async {
    DateTime? newDeadline = await _pickDeadline(initialDate: _todos[index].deadline);
    if (newDeadline != null) {
      setState(() {
        _todos[index].deadline = newDeadline;
      });
      _scheduleDailyNotification();
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
      _scheduleDailyNotification();
    }
  }

  Future<void> _scheduleDailyNotification() async {
    // Cancel previous notification
    await flutterLocalNotificationsPlugin.cancel(0);
    // Find the earliest deadline for today or future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todosWithDeadline = _todos.where((t) => t.deadline != null && !t.deadline!.isBefore(today)).toList();
    if (todosWithDeadline.isEmpty) return;
    // Find the earliest deadline for today
    final todayTodos = todosWithDeadline.where((t) => t.deadline!.year == now.year && t.deadline!.month == now.month && t.deadline!.day == now.day).toList();
    if (todayTodos.isEmpty) return;
    // Compose notification body
    final body = todayTodos.length == 1
        ? todayTodos.first.text
        : 'You have ${todayTodos.length} todos due today!';
    // Schedule notification for the soonest deadline today
    final soonest = todayTodos.reduce((a, b) => a.deadline!.isBefore(b.deadline!) ? a : b);
    final scheduledTime = tz.TZDateTime.from(soonest.deadline!, tz.local);
    final androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'Todo Deadlines',
      channelDescription: 'Notifications for todo deadlines',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Todo Deadline',
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
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
