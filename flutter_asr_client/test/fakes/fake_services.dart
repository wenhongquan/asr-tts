import 'dart:async';

import 'package:asr_client/models/websocket_message.dart';
import 'package:asr_client/services/audio_capture_service.dart';
import 'package:asr_client/services/settings_service.dart';
import 'package:asr_client/services/websocket_service.dart' as ws;

class FakeSettingsService implements SettingsService {
  @override
  Future<String> getHost() async => 'localhost';

  @override
  Future<int> getPort() async => 8765;

  @override
  Future<void> setHost(String host) async {}

  @override
  Future<void> setPort(int port) async {}

  @override
  String getWebSocketUrl(String host, int port) => 'ws://$host:$port';
}

class FakeWebSocketService implements ws.WebSocketService {
  final _messageController = StreamController<ServerMessage>.broadcast();
  final _stateController = StreamController<ws.ConnectionState>.broadcast();
  var _state = ws.ConnectionState.disconnected;
  final _sent = <WebSocketMessage>[];

  List<WebSocketMessage> get sentMessages => List.unmodifiable(_sent);

  void emit(ServerMessage message) => _messageController.add(message);

  @override
  Stream<ServerMessage> get messageStream => _messageController.stream;

  @override
  Stream<ws.ConnectionState> get connectionStateStream =>
      _stateController.stream;

  @override
  ws.ConnectionState get currentState => _state;

  @override
  Future<void> connect(String url) async {
    _state = ws.ConnectionState.connected;
    _stateController.add(ws.ConnectionState.connected);
  }

  @override
  void send(WebSocketMessage message) {
    _sent.add(message);
  }

  @override
  void disconnect() {
    _state = ws.ConnectionState.disconnected;
  }

  void dispose() {
    _messageController.close();
    _stateController.close();
  }
}

class FakeAudioCaptureService implements AudioCaptureService {
  final _levelController = StreamController<double>.broadcast();
  var _recording = false;
  String chunkData = '';

  @override
  Stream<double> get audioLevelStream => _levelController.stream;

  @override
  bool get isRecording => _recording;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> startRecording() async {
    _recording = true;
  }

  @override
  Future<void> stopRecording() async {
    _recording = false;
  }

  @override
  Future<String> readLatestChunkAsBase64() async {
    if (chunkData.isEmpty || !_recording) return '';
    return chunkData;
  }

  @override
  void dispose() {
    _levelController.close();
  }
}
