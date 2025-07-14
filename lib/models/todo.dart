final String tableTodo = 'todo';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnDeadline = 'deadline';
final String columnIsDone = 'is_done';
class Todo {
  int? id;
  String text;
  DateTime? deadline;
  bool isDone = false;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnTitle: text,
      columnDeadline: deadline?.toIso8601String(),
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Todo({required this.text, this.deadline, this.id});

  Todo.fromMap(Map<String, Object?> map)
      : id = map[columnId] as int?,
        text = map[columnTitle] as String,
        deadline = map[columnDeadline] != null
            ? DateTime.parse(map[columnDeadline] as String)
            : null,
        isDone = map[columnIsDone] == 1 ? true : false;
}