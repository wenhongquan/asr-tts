import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:asr_client/models/websocket_message.dart';
import 'package:asr_client/pages/history/history_page.dart';
import 'package:asr_client/pages/profile/profile_page.dart';
import 'package:asr_client/pages/recording/recording_page.dart';
import 'package:asr_client/pages/recording/widgets/recording_header.dart';
import 'package:asr_client/pages/shell/app_shell.dart';
import 'package:asr_client/pages/tasks/tasks_page.dart';
import 'package:asr_client/providers/audio_providers.dart';
import 'package:asr_client/providers/settings_providers.dart';
import 'package:asr_client/providers/websocket_providers.dart';
import 'package:asr_client/theme/app_theme.dart';

import '../test/fakes/fake_services.dart';

class _IntegrationTestApp extends StatelessWidget {
  const _IntegrationTestApp({required this.overrides, required this.router});

  final List<Override> overrides;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        title: '检测数据采集',
        theme: AppTheme.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

GoRouter _buildRouter() {
  final rootNavKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavKey,
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
        parentNavigatorKey: rootNavKey,
        builder: (context, state) => const RecordingPage(),
      ),
    ],
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxIterations = 50,
}) async {
  for (var i = 0; i < maxIterations; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App flow', () {
    late FakeWebSocketService fakeWebSocket;
    late FakeAudioCaptureService fakeAudio;

    setUp(() {
      fakeWebSocket = FakeWebSocketService();
      fakeAudio = FakeAudioCaptureService();
    });

    tearDown(() {
      fakeWebSocket.dispose();
      fakeAudio.dispose();
    });

    testWidgets('navigates tabs and records a transcript', (tester) async {
      await tester.pumpWidget(
        _IntegrationTestApp(
          overrides: [
            settingsServiceProvider.overrideWithValue(FakeSettingsService()),
            webSocketServiceProvider.overrideWithValue(fakeWebSocket),
            audioCaptureServiceProvider.overrideWithValue(fakeAudio),
          ],
          router: _buildRouter(),
        ),
      );

      await _pumpUntil(tester, find.text('今日任务'));
      expect(find.text('今日任务'), findsOneWidget);

      await tester.tap(find.text('记录'));
      await _pumpUntil(tester, find.text('检测记录'));
      expect(find.text('检测记录'), findsOneWidget);

      await tester.tap(find.text('报告'));
      await _pumpUntil(tester, find.text('检测记录'));
      expect(find.text('检测记录'), findsOneWidget);

      await tester.tap(find.text('我的'));
      await _pumpUntil(tester, find.text('采集设置'));
      expect(find.text('采集设置'), findsOneWidget);

      await tester.tap(find.text('任务'));
      await _pumpUntil(tester, find.text('今日任务'));

      await tester.tap(find.byIcon(Icons.add));
      await _pumpUntil(tester, find.text('实时语音识别'));
      await _pumpUntil(tester, find.text('⏸ 暂停'));
      final headerFinder = find.byType(RecordingHeader);
      expect(headerFinder, findsOneWidget);
      final header = tester.widget<RecordingHeader>(headerFinder);
      expect(header.taskName, '混凝土坍落度试验');
      expect(
        find.descendant(of: headerFinder, matching: find.text('混凝土坍落度试验')),
        findsOneWidget,
      );
      expect(find.text('⏸ 暂停'), findsOneWidget);

      fakeWebSocket.emit(const TranscriptMessage(text: '坍落度 180'));
      await _pumpUntil(tester, find.textContaining('坍落度 180'));
      expect(find.textContaining('坍落度 180'), findsOneWidget);
      expect(find.text('AI'), findsWidgets);

      await tester.tap(find.text('⏸ 暂停'));
      await _pumpUntil(tester, find.text('▶ 继续'));
      expect(find.text('▶ 继续'), findsOneWidget);

      await tester.tap(find.text('▶ 继续'));
      await _pumpUntil(tester, find.text('⏸ 暂停'));
      expect(find.text('⏸ 暂停'), findsOneWidget);
    });
  });
}
