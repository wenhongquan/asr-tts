import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:asr_client/common/constants.dart';

abstract interface class SettingsService {
  Future<String> getHost();
  Future<int> getPort();
  Future<void> setHost(String host);
  Future<void> setPort(int port);
  String getWebSocketUrl(String host, int port);
}

final class SharedPreferencesSettingsService implements SettingsService {
  SharedPreferencesSettingsService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<String> getHost() async {
    final prefs = await _preferences;
    final raw = prefs.getString(_hostKey);
    if (raw == null || raw.trim().isEmpty) return AppConstants.defaultHost;
    // `localhost` does not resolve reliably on Android and triggers
    // "no address associated with hostname". Map it to the emulator's
    // host-loopback alias so a previously saved `localhost` still works.
    if (raw.trim().toLowerCase() == 'localhost' && Platform.isAndroid) {
      return '10.0.2.2';
    }
    return raw.trim();
  }

  @override
  Future<int> getPort() async {
    final prefs = await _preferences;
    return prefs.getInt(_portKey) ?? AppConstants.defaultPort;
  }

  @override
  Future<void> setHost(String host) async {
    final prefs = await _preferences;
    await prefs.setString(_hostKey, host.trim());
  }

  @override
  Future<void> setPort(int port) async {
    final prefs = await _preferences;
    await prefs.setInt(_portKey, port);
  }

  @override
  String getWebSocketUrl(String host, int port) => 'ws://$host:$port';

  static const _hostKey = 'asr_host';
  static const _portKey = 'asr_port';
}
