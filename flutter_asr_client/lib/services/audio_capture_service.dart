import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'package:asr_client/common/constants.dart';

abstract interface class AudioCaptureService {
  Stream<double> get audioLevelStream;
  Future<bool> requestPermission();
  Future<bool> get isPermissionPermanentlyDenied;
  Future<void> openSettings();
  Future<void> startRecording();
  Future<void> stopRecording();
  Uint8List? takeBuffer();
  bool get isRecording;
  void dispose();
}

final class AudioCaptureServiceImpl implements AudioCaptureService {
  AudioCaptureServiceImpl({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final _levelController = StreamController<double>.broadcast();
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  String? _path;
  var _readOffset = 0;
  bool _isRecording = false;

  @override
  Stream<double> get audioLevelStream => _levelController.stream;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<bool> requestPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<bool> get isPermissionPermanentlyDenied async => false;

  @override
  Future<void> openSettings() async {}

  @override
  Future<void> startRecording() async {
    if (_isRecording) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    final dir = await Directory.systemTemp.createTemp('asr_');
    final path =
        '${dir.path}/asr_buffer_${DateTime.now().millisecondsSinceEpoch}.pcm';
    _path = path;
    _readOffset = 0;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: AppConstants.targetSampleRate,
        numChannels: 1,
      ),
      path: path,
    );

    _amplitudeSubscription = _recorder.onAmplitudeChanged(
      const Duration(milliseconds: 200),
    ).listen((amp) {
      final normalized = ((amp.current + 160) / 160).clamp(0.0, 1.0);
      _levelController.add(normalized);
    });

    _isRecording = true;
  }

  @override
  Future<void> stopRecording() async {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
      _levelController.add(0);
    }
  }

  @override
  Uint8List? takeBuffer() {
    final path = _path;
    if (path == null) return null;
    final file = File(path);
    if (!file.existsSync()) return null;

    RandomAccessFile? raf;
    try {
      raf = file.openSync(mode: FileMode.read);
      final length = raf.lengthSync();
      if (length <= _readOffset) return null;

      final available = length - _readOffset;
      raf.setPositionSync(_readOffset);
      final bytes = raf.readSync(available);
      _readOffset += available;
      return bytes;
    } catch (_) {
      return null;
    } finally {
      raf?.closeSync();
    }
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _levelController.close();
    _recorder.dispose();
  }
}
