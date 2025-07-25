import 'package:sqflite/sqflite.dart';
import 'package:tak/models/todo.dart';

class TodoProvider {
  Database? db;

  Future<void> init() async {
    
    await open('todos.db');
  }

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
                create table $tableTodo ( 
                  $columnId integer primary key autoincrement, 
                  $columnTitle text not null,
                  $columnDeadline date,
                  $columnCreatedAt date not null default current_timestamp,
                  $columnIsDone integer not null default 0)
    ''');
    });
  }

  Future<Todo> insert(Todo todo) async {
    todo.id = await db!.insert(tableTodo, todo.toMap());
    return todo;
  }

  Future<Todo?> getTodo(int id) async {
    List<Map> maps = await db!.query(tableTodo,
        columns: [columnId, columnTitle],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Todo.fromMap(Map<String, Object?>.from(maps.first));
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db!.delete(tableTodo, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    return await db!.update(tableTodo, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db!.close();

  getAllTodos() async {
    if (db == null) {
      throw Exception("Database not initialized. Call init() first.");
    }
    return await db!.query(tableTodo, orderBy: '$columnId DESC').then((List<Map<String, dynamic>> maps) {
      return List.generate(maps.length, (i) {
        return Todo.fromMap(Map<String, Object?>.from(maps[i]));
      });
    });
  }

  markTodoAsDone(int id, bool marking) async {
    return await db!.update(tableTodo, {columnIsDone: (marking ? 1 : 0)},
        where: '$columnId = ?', whereArgs: [id]);
  }
}