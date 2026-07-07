import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:asr_client/models/websocket_message.dart';
import 'package:asr_client/pages/recording/notifiers/recording_notifier.dart';
import 'package:asr_client/providers/audio_providers.dart';
import 'package:asr_client/providers/settings_providers.dart';
import 'package:asr_client/providers/websocket_providers.dart';

import '../../fakes/fake_services.dart';

void main() {
  group('RecordingNotifier', () {
    late FakeSettingsService fakeSettings;
    late FakeWebSocketService fakeWebSocket;
    late FakeAudioCaptureService fakeAudio;
    late ProviderContainer container;

    setUp(() {
      fakeSettings = FakeSettingsService();
      fakeWebSocket = FakeWebSocketService();
      fakeAudio = FakeAudioCaptureService();

      container = ProviderContainer(
        overrides: [
          settingsServiceProvider.overrideWithValue(fakeSettings),
          webSocketServiceProvider.overrideWithValue(fakeWebSocket),
          audioCaptureServiceProvider.overrideWithValue(fakeAudio),
        ],
      );
      final sub = container.listen(
        recordingNotifierProvider,
        (previous, next) {},
      );
      addTearDown(sub.close);
    });

    tearDown(() {
      fakeWebSocket.dispose();
      fakeAudio.dispose();
      container.dispose();
    });

    test('initial build connects WebSocket and starts recording', () async {
      final future = container.read(recordingNotifierProvider.future);
      final state = await future;

      expect(state.status, RecordingStatus.recording);
      expect(state.isConnected, false);
      expect(fakeAudio.isRecording, true);
    });

    test('pause and resume toggle recording state', () async {
      await container.read(recordingNotifierProvider.future);
      final notifier = container.read(recordingNotifierProvider.notifier);

      notifier.pauseRecording();
      expect(
        container.read(recordingNotifierProvider).value?.status,
        RecordingStatus.paused,
      );
      expect(fakeAudio.isRecording, false);

      await notifier.resumeRecording();
      await pumpEventQueue();

      expect(
        container.read(recordingNotifierProvider).value?.status,
        RecordingStatus.recording,
      );
      expect(fakeAudio.isRecording, true);
    });

    test('transcript message adds conversation items', () async {
      await container.read(recordingNotifierProvider.future);
      fakeWebSocket.emit(const TranscriptMessage(text: '坍落度'));

      await pumpEventQueue();

      final state = container.read(recordingNotifierProvider).value;
      expect(state?.items.length, 2);
      expect(state?.items.first.text, '坍落度');
    });

    test('confirmEnd resets state', () async {
      await container.read(recordingNotifierProvider.future);
      fakeWebSocket.emit(const TranscriptMessage(text: '测试'));
      await pumpEventQueue();

      final notifier = container.read(recordingNotifierProvider.notifier);
      await notifier.confirmEnd();

      final state = container.read(recordingNotifierProvider).value;
      expect(state?.status, RecordingStatus.idle);
      expect(state?.items, isEmpty);
      expect(state?.elapsed, Duration.zero);
      expect(fakeAudio.isRecording, false);
    });

    test('sends audio chunks while recording', () async {
      fakeAudio.chunkData = 'Zm9v';
      await container.read(recordingNotifierProvider.future);

      await Future.delayed(const Duration(milliseconds: 500));

      final audioMessages = fakeWebSocket.sentMessages
          .whereType<AudioMessage>();
      expect(audioMessages, isNotEmpty);
      expect(audioMessages.first.data, 'Zm9v');
    });

    test('stops sending audio chunks after pause', () async {
      fakeAudio.chunkData = 'YmFy';
      await container.read(recordingNotifierProvider.future);

      await Future.delayed(const Duration(milliseconds: 350));
      container.read(recordingNotifierProvider.notifier).pauseRecording();
      final sentBeforePause = fakeWebSocket.sentMessages
          .whereType<AudioMessage>()
          .length;
      expect(sentBeforePause, greaterThanOrEqualTo(1));

      await Future.delayed(const Duration(milliseconds: 400));
      final sentAfterPause = fakeWebSocket.sentMessages
          .whereType<AudioMessage>()
          .length;
      expect(sentAfterPause, sentBeforePause);
    });
  });
}
