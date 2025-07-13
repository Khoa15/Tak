import 'package:flutter_test/flutter_test.dart';
import 'package:tak/models/todo.dart';

void main() {
  group('Todo', () {
    test('can create a todo with text', () {
      final todo = Todo(text: 'Test todo');
      expect(todo.text, 'Test todo');
      expect(todo.deadline, isNull);
    });

    test('can create a todo with deadline', () {
      final deadline = DateTime(2025, 7, 4);
      final todo = Todo(text: 'Test with deadline', deadline: deadline);
      expect(todo.deadline, deadline);
    });

    test('can edit todo text', () {
      final todo = Todo(text: 'Old text');
      todo.text = 'New text';
      expect(todo.text, 'New text');
    });

    test('can set and update deadline', () {
      final todo = Todo(text: 'Deadline test');
      final deadline1 = DateTime(2025, 7, 4);
      final deadline2 = DateTime(2025, 7, 5);
      todo.deadline = deadline1;
      expect(todo.deadline, deadline1);
      todo.deadline = deadline2;
      expect(todo.deadline, deadline2);
    });
  });
}
