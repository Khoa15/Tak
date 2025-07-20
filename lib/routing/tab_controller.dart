import 'package:flutter/material.dart';
import 'package:tak/ui/screens/statistics/statistics_screen.dart';
import 'package:tak/ui/screens/todo/todo_screen.dart';
import '../ui/screens/timer/pomodoro_timer_screen.dart';

class AppTabController extends StatefulWidget {
  const AppTabController({super.key});

  @override
  State<AppTabController> createState() => _AppTabControllerState();
}

class _AppTabControllerState extends State<AppTabController> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    TodoScreen(),
    const PomodoroTimer(),
    StatisticsScreen(),
  ];
  final Map<String, IconData> _tabIcons = {
    'Todos': Icons.list,
    'Pomodoro': Icons.timer,
    'Statistics': Icons.bar_chart,
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: _pages[_selectedIndex],
      body: Stack(
        children: [
          Column(children: [Expanded(child: _pages[_selectedIndex])]),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        // shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _tabIcons.length, 
            (index) => IconButton(
                onPressed: () => _onItemTapped(index),
                icon: Icon(_tabIcons.values.elementAt(index)),
                color: (_selectedIndex == index) ? Colors.blue : Colors.black,
              )
            )
          // [
          //   IconButton(
          //     onPressed: () => _onItemTapped(0),
          //     icon: const Icon(Icons.list),
          //   ),
          //   IconButton(
          //     onPressed: () => _onItemTapped(1),
          //     icon: const Icon(Icons.timer),
          //   ),
          //   IconButton(
          //     onPressed: () => _onItemTapped(2),
          //     icon: const Icon(Icons.bar_chart),
          //     color: Colors.blue,
          //   ),
          // ],
        ),
      ),
      // BottomNavigationBar(
      //   items: _tabIcons.keys
      //       .map((title) => BottomNavigationBarItem(
      //             icon: Icon(_tabIcons[title]),
      //             label: title,
      //           ))
      //       .toList(),
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   selectedItemColor: Theme.of(context).colorScheme.primary,
      //   unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      //   showUnselectedLabels: true,
      //   selectedFontSize: 12,
      // ),
    );
  }
}
