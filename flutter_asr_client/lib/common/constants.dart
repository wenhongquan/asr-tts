abstract final class AppConstants {
  static const defaultHost = 'localhost';
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
