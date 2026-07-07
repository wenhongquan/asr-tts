import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:asr_client/common/constants.dart';

abstract interface class AudioCaptureService {
  Stream<double> get audioLevelStream;
  Future<bool> requestPermission();
  Future<bool> get isPermissionPermanentlyDenied;
  Future<void> openSettings();
  Future<void> startRecording();
  Future<void> stopRecording();
  Future<String> readLatestChunkAsBase64();
  bool get isRecording;
  void dispose();
}

final class AudioCaptureServiceImpl implements AudioCaptureService {
  AudioCaptureServiceImpl({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final _levelController = StreamController<double>.broadcast();
  StreamSubscription? _amplitudeSubscription;
  String? _latestPath;
  var _readOffset = 0;
  bool _isRecording = false;

  @override
  Stream<double> get audioLevelStream => _levelController.stream;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<bool> requestPermission() async {
    // Use record's native hasPermission() which reads AVAudioSession directly.
    // permission_handler is broken on iOS 18 Simulator (always returns
    // permanentlyDenied even when TCC.db shows granted).
    final hasPermission = await _recorder.hasPermission();
    if (hasPermission) return true;

    // Fallback: trigger permission_handler to show the system dialog.
    final status = await Permission.microphone.request();
    if (status.isGranted) return true;

    // Last resort: re-check record in case the dialog just granted it.
    return await _recorder.hasPermission();
  }

  @override
  Future<bool> get isPermissionPermanentlyDenied async => false;

  @override
  Future<void> openSettings() => openAppSettings();

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
    _latestPath = path;
    _readOffset = 0;
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: AppConstants.targetSampleRate,
        numChannels: 1,
      ),
      path: path,
    );

    _isRecording = true;
  }

  @override
  Future<void> stopRecording() async {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    if (_isRecording) {
      _latestPath = await _recorder.stop();
      _isRecording = false;
      _levelController.add(0);
    }
  }

  @override
  Future<String> readLatestChunkAsBase64() async {
    final path = _latestPath;
    if (path == null) return '';

    final file = File(path);
    if (!await file.exists()) return '';

    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.read);
      final length = await raf.length();
      if (length <= _readOffset) return '';

      final available = length - _readOffset;
      final count = available > AppConstants.maxAudioChunkBytes
          ? AppConstants.maxAudioChunkBytes
          : available;
      if (count <= 0) return '';

      await raf.setPosition(_readOffset);
      final bytes = await raf.read(count);
      _readOffset += count;
      return base64Encode(bytes);
    } on Exception catch (_) {
      return '';
    } finally {
      await raf?.close();
    }
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _levelController.close();
    _recorder.dispose();
  }
}
