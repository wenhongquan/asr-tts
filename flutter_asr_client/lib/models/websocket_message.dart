import 'dart:convert';

sealed class WebSocketMessage {
  const WebSocketMessage();

  Map<String, dynamic> toJson();

  String toJsonString() => jsonEncode(toJson());
}

final class AudioMessage extends WebSocketMessage {
  const AudioMessage({required this.data});

  final String data;

  @override
  Map<String, dynamic> toJson() => {'type': 'audio', 'data': data};
}

final class TranscribeMessage extends WebSocketMessage {
  const TranscribeMessage();

  @override
  Map<String, dynamic> toJson() => {'type': 'transcribe'};
}

final class ClearMessage extends WebSocketMessage {
  const ClearMessage();

  @override
  Map<String, dynamic> toJson() => {'type': 'clear'};
}

sealed class ServerMessage {
  const ServerMessage();

  static ServerMessage fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'connected':
        return ConnectedMessage(
          model: json['model'] as Map<String, dynamic>? ?? const {},
        );
      case 'transcript':
        return TranscriptMessage(
          text: json['text'] as String? ?? '',
          language: json['language'] as String?,
        );
      case 'cleared':
        return const ClearedMessage();
      case 'error':
        return ErrorMessage(
          message: json['message'] as String? ?? 'Unknown error',
        );
      default:
        return ErrorMessage(message: 'Unknown message type: $type');
    }
  }

  static ServerMessage fromJsonString(String source) {
    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      return fromJson(json);
    } on FormatException catch (e) {
      return ErrorMessage(message: 'Invalid JSON: $e');
    }
  }
}

final class ConnectedMessage extends ServerMessage {
  const ConnectedMessage({required this.model});

  final Map<String, dynamic> model;
}

final class TranscriptMessage extends ServerMessage {
  const TranscriptMessage({required this.text, this.language});

  final String text;
  final String? language;
}

final class ClearedMessage extends ServerMessage {
  const ClearedMessage();
}

final class ErrorMessage extends ServerMessage {
  const ErrorMessage({required this.message});

  final String message;
}
