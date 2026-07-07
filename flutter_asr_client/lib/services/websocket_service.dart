import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'package:asr_client/common/constants.dart';
import 'package:asr_client/models/websocket_message.dart';

export 'package:asr_client/models/websocket_message.dart' show ServerMessage;

enum ConnectionState { disconnected, connecting, connected, error }

abstract interface class WebSocketService {
  Stream<ServerMessage> get messageStream;
  Stream<ConnectionState> get connectionStateStream;
  ConnectionState get currentState;

  Future<void> connect(String url);
  void send(WebSocketMessage message);
  void disconnect();
}

final class WebSocketServiceImpl implements WebSocketService {
  WebSocketServiceImpl();

  WebSocketChannel? _channel;
  final _messageController = StreamController<ServerMessage>.broadcast();
  final _stateController = StreamController<ConnectionState>.broadcast();
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  String? _currentUrl;
  bool _shouldReconnect = false;
  var _reconnectAttempt = 0;

  @override
  Stream<ServerMessage> get messageStream => _messageController.stream;

  @override
  Stream<ConnectionState> get connectionStateStream => _stateController.stream;

  @override
  ConnectionState get currentState => _lastState;

  ConnectionState _lastState = ConnectionState.disconnected;

  void _setState(ConnectionState state) {
    _lastState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  @override
  Future<void> connect(String url) async {
    if (_lastState == ConnectionState.connecting ||
        _lastState == ConnectionState.connected) {
      return;
    }
    _currentUrl = url;
    _shouldReconnect = true;
    await _connectInternal(url);
  }

  Future<void> _connectInternal(String url) async {
    _setState(ConnectionState.connecting);
    try {
      final socket = await WebSocket.connect(
        url,
      ).timeout(const Duration(seconds: 10));
      _channel = IOWebSocketChannel(socket);

      _channel!.stream.listen(
        (event) {
          if (event is String) {
            final message = ServerMessage.fromJsonString(event);
            _messageController.add(message);
          }
        },
        onError: (Object error) {
          _setState(ConnectionState.error);
          _messageController.add(
            ErrorMessage(message: 'WebSocket error: $error'),
          );
          _scheduleReconnect();
        },
        onDone: () {
          _setState(ConnectionState.disconnected);
          _scheduleReconnect();
        },
      );

      _setState(ConnectionState.connected);
      _reconnectAttempt = 0;
      _startPingTimer();
    } on Exception catch (e) {
      _setState(ConnectionState.error);
      _messageController.add(ErrorMessage(message: 'Connection failed: $e'));
      _scheduleReconnect();
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(AppConstants.pingInterval, (_) {
      _channel?.sink.add(jsonEncode({'type': 'ping'}));
    });
  }

  void _scheduleReconnect() {
    _pingTimer?.cancel();
    _channel = null;
    if (!_shouldReconnect || _currentUrl == null) return;

    final delay = Duration(
      seconds: math.min(
        AppConstants.reconnectBaseDelay.inSeconds *
            math.pow(2, _reconnectAttempt).toInt(),
        AppConstants.reconnectMaxDelay.inSeconds,
      ),
    );
    _reconnectAttempt++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect && _currentUrl != null) {
        unawaited(_connectInternal(_currentUrl!));
      }
    });
  }

  @override
  void send(WebSocketMessage message) {
    if (_channel != null && _lastState == ConnectionState.connected) {
      _channel!.sink.add(message.toJsonString());
    }
  }

  @override
  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _setState(ConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _stateController.close();
  }
}
