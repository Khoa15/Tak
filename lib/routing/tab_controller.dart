import 'package:flutter/material.dart';
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
    const TodoScreen(),
    const PomodoroTimer(),
  ];
  final List<String> _tabTitles = [
    'Todos',
    'Pomodoro',
  ];

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
        items: _tabTitles
            .map((title) => BottomNavigationBarItem(
                  icon: Icon(
                    title == 'Todos' ? Icons.list : Icons.timer,
                  ),
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
