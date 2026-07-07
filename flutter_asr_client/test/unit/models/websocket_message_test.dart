import 'package:flutter_test/flutter_test.dart';
import 'package:asr_client/models/websocket_message.dart';

void main() {
  group('WebSocketMessage', () {
    test('AudioMessage encodes to JSON', () {
      const message = AudioMessage(data: 'base64data');
      expect(message.toJsonString(), '{"type":"audio","data":"base64data"}');
    });

    test('TranscribeMessage encodes to JSON', () {
      const message = TranscribeMessage();
      expect(message.toJsonString(), '{"type":"transcribe"}');
    });

    test('ClearMessage encodes to JSON', () {
      const message = ClearMessage();
      expect(message.toJsonString(), '{"type":"clear"}');
    });
  });

  group('ServerMessage', () {
    test('parses connected message', () {
      final message = ServerMessage.fromJsonString(
        '{"type":"connected","model":{"name":"tiny"}}',
      );
      expect(message, isA<ConnectedMessage>());
      expect((message as ConnectedMessage).model['name'], 'tiny');
    });

    test('parses transcript message', () {
      final message = ServerMessage.fromJsonString(
        '{"type":"transcript","text":"hello","language":"en"}',
      );
      expect(message, isA<TranscriptMessage>());
      expect((message as TranscriptMessage).text, 'hello');
      expect(message.language, 'en');
    });

    test('parses cleared message', () {
      final message = ServerMessage.fromJsonString('{"type":"cleared"}');
      expect(message, isA<ClearedMessage>());
    });

    test('parses error message', () {
      final message = ServerMessage.fromJsonString(
        '{"type":"error","message":"oops"}',
      );
      expect(message, isA<ErrorMessage>());
      expect((message as ErrorMessage).message, 'oops');
    });

    test('returns error for invalid JSON', () {
      final message = ServerMessage.fromJsonString('not json');
      expect(message, isA<ErrorMessage>());
    });

    test('returns error for unknown type', () {
      final message = ServerMessage.fromJsonString('{"type":"unknown"}');
      expect(message, isA<ErrorMessage>());
    });
  });
}
