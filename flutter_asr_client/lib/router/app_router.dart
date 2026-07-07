import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/pages/shell/app_shell.dart';
import 'package:asr_client/pages/tasks/tasks_page.dart';
import 'package:asr_client/pages/history/history_page.dart';
import 'package:asr_client/pages/profile/profile_page.dart';
import 'package:asr_client/pages/recording/recording_page.dart';

final GlobalKey<NavigatorState> _rootNavKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/tasks',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/records',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/recording',
        parentNavigatorKey: _rootNavKey,
        builder: (context, state) => const RecordingPage(),
      ),
    ],
  );
});
