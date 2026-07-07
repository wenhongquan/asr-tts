import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/services/audio_capture_service.dart';

final audioCaptureServiceProvider = Provider<AudioCaptureService>(
  (_) => AudioCaptureServiceImpl(),
);

final audioLevelProvider = StreamProvider<double>((ref) {
  final service = ref.watch(audioCaptureServiceProvider);
  ref.onDispose(() {
    if (service is AudioCaptureServiceImpl) {
      service.dispose();
    }
  });
  return service.audioLevelStream;
});
