final String tableTodo = 'todo';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnDeadline = 'deadline';
final String columnIsDone = 'is_done';
final String columnCreatedAt = 'created_at';



class Todo {
  int? id;
  String text;
  DateTime? deadline;
  bool isDone = false;
  DateTime? createdAt = DateTime.now();

  // Map<String, Object?> toMap() {
  //   var map = <String, Object?>{
  //     columnTitle: text,
  //     columnDeadline: deadline?.toIso8601String(),
  //   };
  //   if (id != null) {
  //     map[columnId] = id;
  //   }
  //   return map;
  // }

  Map<String, Object?> toMap() {
    return {
      columnId: id,
      columnTitle: text,
      columnDeadline: deadline?.toIso8601String(),
      columnIsDone: isDone ? 1 : 0,
      columnCreatedAt: DateTime.now().toIso8601String()
    };
  }

  Todo({this.id, required this.text, this.deadline, this.isDone = false, this.createdAt});
  // Todo({required this.text, this.deadline, this.id});

  Todo.fromMap(Map<String, Object?> map)
      : id = map[columnId] as int?,
        text = map[columnTitle] as String,
        deadline = map[columnDeadline] != null ? DateTime.parse(map[columnDeadline] as String): null,
        isDone = map[columnIsDone] == 1 ? true : false,
        createdAt = map[columnCreatedAt] != null ? DateTime.parse(map[columnCreatedAt] as String) : null;
}