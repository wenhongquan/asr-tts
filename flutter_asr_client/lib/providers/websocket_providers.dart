import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/providers/settings_providers.dart';
import 'package:asr_client/services/websocket_service.dart';

final webSocketServiceProvider = Provider<WebSocketService>(
  (_) => WebSocketServiceImpl(),
);

final webSocketConnectionProvider = StreamProvider<ConnectionState>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  ref.onDispose(() {
    if (service is WebSocketServiceImpl) {
      service.dispose();
    }
  });
  return service.connectionStateStream;
});

final webSocketMessagesProvider = StreamProvider<ServerMessage>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.messageStream;
});

final autoConnectProvider = FutureProvider<void>((ref) async {
  final service = ref.read(webSocketServiceProvider);
  final url = await ref.read(serverUrlProvider.future);
  unawaited(service.connect(url));
});
