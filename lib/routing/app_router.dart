import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:tak/ui/screens/timer/pomodoro_timer_screen.dart';
import 'package:tak/ui/screens/todo/todo_screen.dart';
import 'package:tak/routing/tab_controller.dart';

class Approuter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, child) => const AppTabController(),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const TodoScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pomodoro',
                builder: (context, state) => const PomodoroTimer(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  
}

  
