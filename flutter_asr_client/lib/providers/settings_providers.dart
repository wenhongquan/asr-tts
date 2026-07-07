import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>(
  (_) => SharedPreferencesSettingsService(),
);

final serverHostProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return service.getHost();
});

final serverPortProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return service.getPort();
});

final serverUrlProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  final host = await service.getHost();
  final port = await service.getPort();
  return service.getWebSocketUrl(host, port);
});
