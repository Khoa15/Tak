import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:tak/core/todo_provider.dart';
import 'package:tak/models/todo.dart';

enum TimeFilter { today, week, month, quarter, year, all }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final TodoProvider _todoProvider = TodoProvider();
  TimeFilter _selectedFilter = TimeFilter.today;
  List<Todo> _filteredTodos = [];
  List<Todo> mockTodos = [];
  int _totalFilteredTodos = 0;
  int _completedFilteredTodos = 0;
  int _pendingFilteredTodos = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
    // _applyFilter(_selectedFilter); // Áp dụng bộ lọc ban đầu
  }

  void _initialize() async {
    await _todoProvider.init();
    _todoProvider
        .getAllTodos()
        .then((todos) {
          if (todos != null) {
            setState(() {
              mockTodos =
                  todos; // Cập nhật danh sách công việc từ cơ sở dữ liệu
              _applyFilter(_selectedFilter); // Áp dụng bộ lọc ban đầu
            });
          }
        })
        .catchError((error) {
          print('Error fetching todos: $error');
        });
  }

  void _applyFilter(TimeFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _filteredTodos = _getFilteredTodos(filter);
      _totalFilteredTodos = _filteredTodos.length;
      _completedFilteredTodos = _filteredTodos
          .where((todo) => todo.isDone)
          .length;
      _pendingFilteredTodos = _totalFilteredTodos - _completedFilteredTodos;
    });
  }

  List<Todo> _getFilteredTodos(TimeFilter filter) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    ); // Cuối ngày hiện tại

    switch (filter) {
      case TimeFilter.today:
        startDate = DateTime(now.year, now.month, now.day); // Đầu ngày hiện tại
        break;
      case TimeFilter.week:
        // Lấy ngày đầu tiên của tuần (ví dụ: Thứ Hai)
        startDate = now.subtract(
          Duration(days: now.weekday - 1),
        ); // Lấy thứ 2 của tuần hiện tại
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case TimeFilter.month:
        startDate = DateTime(now.year, now.month, 1); // Đầu tháng hiện tại
        break;
      case TimeFilter.quarter:
        final currentQuarter = ((now.month - 1) ~/ 3) + 1; // 1-4
        final startMonth = (currentQuarter - 1) * 3 + 1;
        startDate = DateTime(now.year, startMonth, 1); // Đầu quý hiện tại
        break;
      case TimeFilter.year:
        startDate = DateTime(now.year, 1, 1); // Đầu năm hiện tại
        break;
      case TimeFilter.all:
        return mockTodos;
    }

    // Lọc các công việc được tạo trong khoảng thời gian đã chọn
    return mockTodos.where((todo) {
      return todo.createdAt!.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) && // Bắt đầu từ 00:00:00 của startDate
          todo.createdAt!.isBefore(
            endDate.add(const Duration(days: 1)),
          ); // Kết thúc ở 23:59:59 của endDate
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTimeFilterButtons(),
            const SizedBox(height: 20),

            _buildSummaryCard(),
            const SizedBox(height: 20),

            // Text(
            //   'Các công việc trong khoảng thời gian đã chọn',
            //   style: Theme.of(context).textTheme.headlineSmall,
            // ),
            const SizedBox(height: 10),
            _buildFilteredTodoList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterButtons() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: TimeFilter.values.map((filter) {
            return ChoiceChip(
              label: Text(_getFilterLabel(filter)),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                if (selected) {
                  _applyFilter(filter);
                }
              },
              selectedColor: Colors.blueAccent,
              labelStyle: TextStyle(
                color: _selectedFilter == filter
                    ? Colors.white
                    : Colors.black87,
              ),
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.today:
        return 'Hôm nay';
      case TimeFilter.week:
        return 'Tuần này';
      case TimeFilter.month:
        return 'Tháng này';
      case TimeFilter.quarter:
        return 'Quý này';
      case TimeFilter.year:
        return 'Năm nay';
      case TimeFilter.all:
        return 'Tất cả';
    }
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Thống kê theo ${_getFilterLabel(_selectedFilter)}',
            //   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            // ),
            // const Divider(),
            _buildStatRow('Tổng số công việc:', '$_totalFilteredTodos'),
            _buildStatRow(
              'Đã hoàn thành:',
              '$_completedFilteredTodos',
              color: Colors.green,
            ),
            _buildStatRow(
              'Chưa hoàn thành:',
              '$_pendingFilteredTodos',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredTodoList() {
    if (_filteredTodos.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Không có công việc nào trong khoảng thời gian này.'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = _filteredTodos[index];
          return ListTile(
            leading: Icon(
              todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: todo.isDone ? Colors.green : Colors.orange,
            ),
            title: Text(
              todo.text,
              style: TextStyle(
                decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
            ),
            subtitle: Text('Tạo lúc: ${todo.createdAt.toString().split(' ')[0]}'),
          );
          // Row(
          //   children: <Widget>[
          //     Icon(
          //       _todo.isDone
          //           ? Icons.check_circle
          //           : Icons.radio_button_unchecked,
          //       color: _todo.isDone ? Colors.green : Colors.orange,
          //     ),
          //     Expanded(
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             _todo.text,
          //             style: TextStyle(
          //               color: _todo.isDone ? Colors.grey[400] : Colors.black,
          //               decoration: _todo.isDone
          //                   ? TextDecoration.lineThrough
          //                   : TextDecoration.none,
          //             ),
          //           ),
          //           Text(
          //             _todo.deadline!.toLocal().toString().split(' ')[0],
          //             style: TextStyle(
          //               color: _todo.isDone ? Colors.grey[400] : Colors.black,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // );
          
        },
      ),
    );
  }
}
