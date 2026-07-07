import 'dart:io';

abstract final class AppConstants {
  // On the Android emulator `localhost` points at the emulator itself, not the
  // dev machine. `10.0.2.2` is the emulator's alias for the host loopback, so
  // it is the correct default there. Physical devices must set the host
  // explicitly to the dev machine's LAN IP via the server settings dialog.
  static String get defaultHost =>
      Platform.isAndroid ? '192.168.199.195' : '127.0.0.1';
  static const defaultPort = 8765;
  static const targetSampleRate = 16000;
  static const bufferSize = 4096;
  static const transcribeInterval = Duration(seconds: 2);
  static const audioSendInterval = Duration(milliseconds: 300);
  static const maxAudioChunkBytes = 16000;
  static const pingInterval = Duration(seconds: 30);
  static const reconnectBaseDelay = Duration(seconds: 1);
  static const reconnectMaxDelay = Duration(seconds: 30);
  static const appName = '检测数据采集';
}
