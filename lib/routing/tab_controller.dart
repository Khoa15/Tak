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
            Column(
              children: [
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
            // if (isLoading)
            //   Container(
            //     color: Colors.white.withAlpha(100),
            //     alignment: Alignment.center,
            //     child: LoadingAnimationWidget.threeArchedCircle(
            //       color: colorScheme.primary,
            //       size: 48,
            //     ),
            //   )
          ],
        ),
      bottomNavigationBar: BottomNavigationBar(
        items: _tabIcons.keys
            .map((title) => BottomNavigationBarItem(
                  icon: Icon(_tabIcons[title]),
                  label: title,
                ))
            .toList(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        showUnselectedLabels: true,
        selectedFontSize: 12,
      ),
    );
  }
}
