import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:asr_client/pages/recording/recording_page.dart';
import 'package:asr_client/providers/audio_providers.dart';
import 'package:asr_client/providers/settings_providers.dart';
import 'package:asr_client/providers/websocket_providers.dart';

import '../../fakes/fake_services.dart';

void main() {
  testWidgets('RecordingPage shows header and controls', (tester) async {
    final fakeWebSocket = FakeWebSocketService();
    final fakeAudio = FakeAudioCaptureService();
    addTearDown(() {
      fakeWebSocket.dispose();
      fakeAudio.dispose();
    });

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWithValue(FakeSettingsService()),
          webSocketServiceProvider.overrideWithValue(fakeWebSocket),
          audioCaptureServiceProvider.overrideWithValue(fakeAudio),
        ],
        child: const MaterialApp(home: RecordingPage()),
      ),
    );

    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('混凝土坍落度试验').evaluate().isNotEmpty) break;
    }

    expect(find.text('实时语音识别'), findsOneWidget);
    expect(find.text('混凝土坍落度试验'), findsOneWidget);
  });
}
