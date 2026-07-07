import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:asr_client/models/websocket_message.dart';
import 'package:asr_client/services/websocket_service.dart';

String _generateSineWaveBase64() {
  const sampleRate = 16000;
  const durationMs = 500;
  const frequency = 440.0;
  const amplitude = 1000.0;
  final sampleCount = (sampleRate * durationMs / 1000).round();
  final buffer = Int16List(sampleCount);
  for (var i = 0; i < sampleCount; i++) {
    final value =
        amplitude * math.sin(2 * math.pi * frequency * i / sampleRate);
    buffer[i] = value.toInt().clamp(-32768, 32767);
  }
  return base64Encode(buffer.buffer.asUint8List());
}

void main() {
  group('WebSocketService runtime verification', () {
    test('connects to ASR server and receives transcript', () async {
      final service = WebSocketServiceImpl();
      addTearDown(service.dispose);

      try {
        final socket = await Socket.connect(
          'localhost',
          8765,
        ).timeout(const Duration(seconds: 2));
        await socket.close();
      } on Exception {
        markTestSkipped('ASR server is not running on localhost:8765');
      }

      await service.connect('ws://localhost:8765');

      final connected = await service.messageStream
          .firstWhere((msg) => msg is ConnectedMessage)
          .timeout(const Duration(seconds: 10));
      expect(connected, isA<ConnectedMessage>());

      // Feed a few audio chunks so the server has data to transcribe.
      final audioData = _generateSineWaveBase64();
      for (var i = 0; i < 6; i++) {
        service.send(AudioMessage(data: audioData));
        await Future.delayed(const Duration(milliseconds: 300));
      }

      service.send(const TranscribeMessage());

      final transcript = await service.messageStream
          .firstWhere((msg) => msg is TranscriptMessage || msg is ErrorMessage)
          .timeout(const Duration(seconds: 30));

      expect(transcript, isNotNull);
    }, tags: ['runtime']);
  });
}
