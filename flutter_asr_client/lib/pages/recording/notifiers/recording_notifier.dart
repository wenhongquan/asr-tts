import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:asr_client/common/constants.dart';
import 'package:asr_client/models/conversation.dart';
import 'package:asr_client/models/websocket_message.dart';
import 'package:asr_client/providers/audio_providers.dart';
import 'package:asr_client/providers/settings_providers.dart';
import 'package:asr_client/providers/websocket_providers.dart';
import 'package:asr_client/services/audio_capture_service.dart';
import 'package:asr_client/services/websocket_service.dart';

enum RecordingStatus { idle, recording, paused, ending }

@immutable
const _unset = _Unset();
final class _Unset {
  const _Unset();
}

final class RecordingState {
  const RecordingState({
    this.status = RecordingStatus.idle,
    this.elapsed = Duration.zero,
    this.audioLevel = 0.0,
    this.items = const [],
    this.isConnected = false,
    this.errorMessage,
    this.sessionId,
    this.projectName,
    this.taskName,
    this.templateName,
  });

  final RecordingStatus status;
  final Duration elapsed;
  final double audioLevel;
  final List<ConversationItem> items;
  final bool isConnected;
  final String? errorMessage;
  final String? sessionId;
  final String? projectName;
  final String? taskName;
  final String? templateName;

  RecordingState copyWith({
    RecordingStatus? status,
    Duration? elapsed,
    double? audioLevel,
    List<ConversationItem>? items,
    bool? isConnected,
    Object? errorMessage = _unset,
    Object? sessionId = _unset,
    Object? projectName = _unset,
    Object? taskName = _unset,
    Object? templateName = _unset,
  }) {
    return RecordingState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      audioLevel: audioLevel ?? this.audioLevel,
      items: items ?? this.items,
      isConnected: isConnected ?? this.isConnected,
      errorMessage:
          identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      sessionId:
          identical(sessionId, _unset) ? this.sessionId : sessionId as String?,
      projectName: identical(projectName, _unset)
          ? this.projectName
          : projectName as String?,
      taskName: identical(taskName, _unset) ? this.taskName : taskName as String?,
      templateName: identical(templateName, _unset)
          ? this.templateName
          : templateName as String?,
    );
  }

  bool get isRecording => status == RecordingStatus.recording;
  bool get isPaused => status == RecordingStatus.paused;
}

final recordingNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RecordingNotifier, RecordingState>(
      RecordingNotifier.new,
    );

final class RecordingNotifier extends AutoDisposeAsyncNotifier<RecordingState> {
  Timer? _timer;
  Timer? _transcribeTimer;
  Timer? _audioSendTimer;
  final _uuid = const Uuid();
  DateTime? _startTime;
  Duration _accumulated = Duration.zero;
  var _isSendingAudio = false;

  WebSocketService get _webSocketService => ref.read(webSocketServiceProvider);

  AudioCaptureService get _audioCaptureService =>
      ref.read(audioCaptureServiceProvider);

  @override
  FutureOr<RecordingState> build() async {
    ref.onDispose(() {
      _timer?.cancel();
      _transcribeTimer?.cancel();
      _audioSendTimer?.cancel();
    });

    final initialState = const RecordingState(
      sessionId: 'LC-20260707-03',
      projectName: 'G15 沈海高速改扩建 · K1120+300',
      taskName: '混凝土坍落度试验',
      templateName: '模板 · 普通混凝土坍落度 GB/T 50080',
    );

    try {
      await _connectWebSocket();
    } on Exception catch (e) {
      state = AsyncData(
        initialState.copyWith(
          status: RecordingStatus.idle,
          errorMessage: '无法连接服务器: $e',
        ),
      );
      return state.value ?? initialState;
    }
    if (_webSocketService.currentState != ConnectionState.connected) {
      state = AsyncData(
        initialState.copyWith(
          status: RecordingStatus.idle,
          errorMessage: '无法连接服务器，请检查服务端地址与网络后重试',
        ),
      );
      return state.value ?? initialState;
    }
    await _startRecording(initialState);
    // Also set isConnected from the actual WebSocket state, because the
    // server's 'connected' message may have arrived before the listener was
    // attached (broadcast stream doesn't buffer).
    if (_webSocketService.currentState == ConnectionState.connected) {
      _updateState((s) => s.copyWith(isConnected: true));
    }
    return state.value ?? initialState;
  }

  Future<void> _connectWebSocket() async {
    final url = await ref.read(serverUrlProvider.future);
    await _webSocketService.connect(url);
  }

  Future<void> _startRecording(RecordingState initialState) async {
    try {
      final hasPermission = await _audioCaptureService.requestPermission();
      if (!hasPermission) {
        final permanentlyDenied =
            await _audioCaptureService.isPermissionPermanentlyDenied;
        if (permanentlyDenied) {
          await _audioCaptureService.openSettings();
        }
        state = AsyncData(
          initialState.copyWith(
            status: RecordingStatus.idle,
            errorMessage: permanentlyDenied
                ? '麦克风权限被拒绝，请在系统设置中开启后重试'
                : '需要麦克风权限才能进行录音',
          ),
        );
        return;
      }

      await _audioCaptureService.startRecording();
      state = AsyncData(
        initialState.copyWith(status: RecordingStatus.recording),
      );
      _startTimer();
      _startTranscribeTimer();
      _startAudioSendTimer();
      _listenToAudioLevel();
      _listenToWebSocketMessages();
    } on Exception catch (e) {
      state = AsyncData(
        initialState.copyWith(
          status: RecordingStatus.idle,
          errorMessage: '录音启动失败: $e',
        ),
      );
    }
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final elapsed =
          _accumulated +
          (_startTime != null ? now.difference(_startTime!) : Duration.zero);
      _updateState((s) => s.copyWith(elapsed: elapsed));
    });
  }

  void _startTranscribeTimer() {
    _transcribeTimer?.cancel();
    _transcribeTimer = Timer.periodic(AppConstants.transcribeInterval, (_) {
      if (state.value?.isRecording ?? false) {
        _webSocketService.send(const TranscribeMessage());
      }
    });
  }

  void _startAudioSendTimer() {
    _audioSendTimer?.cancel();
    _audioSendTimer = Timer.periodic(AppConstants.audioSendInterval, (_) async {
      if (!(state.value?.isRecording ?? false) || _isSendingAudio) return;
      _isSendingAudio = true;
      try {
        final chunk = await _audioCaptureService.readLatestChunkAsBase64();
        if (chunk.isNotEmpty) {
          _webSocketService.send(AudioMessage(data: chunk));
        }
      } on Exception catch (_) {
        // Swallow single chunk errors; the next tick will retry.
      } finally {
        _isSendingAudio = false;
      }
    });
  }

  void _listenToAudioLevel() {
    _audioCaptureService.audioLevelStream.listen(
      (level) => _updateState((s) => s.copyWith(audioLevel: level)),
      onError: (_) {},
    );
  }

  void _listenToWebSocketMessages() {
    _webSocketService.messageStream.listen((message) {
      switch (message) {
        case ConnectedMessage():
          _updateState((s) => s.copyWith(isConnected: true));
        case TranscriptMessage(:final text):
          _addTranscript(text);
        case ErrorMessage(:final message):
          _updateState((s) => s.copyWith(errorMessage: message));
        case ClearedMessage():
          break;
      }
    }, onError: (_) {});
  }

  void _addTranscript(String text) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);

    _updateState(
      (s) => s.copyWith(
        items: [
          ...s.items,
          ConversationItem(
            id: _uuid.v4(),
            type: ConversationItemType.userBubble,
            timestamp: now,
            text: text,
          ),
          _buildAiResponse(text, now, timeStr),
        ],
      ),
    );
  }

  ConversationItem _buildAiResponse(
    String text,
    DateTime time,
    String timeStr,
  ) {
    if (text.contains('坍落度')) {
      return ConversationItem(
        id: _uuid.v4(),
        type: ConversationItemType.aiCard,
        timestamp: time,
        aiLabel: 'AI',
        aiSubLabel: '结构化 · 已校验',
        fields: [
          const AiField(key: '指标', value: '坍落度'),
          const AiField(key: '仪器', value: '坍落度筒'),
          const AiField(key: '实测', value: '180 mm'),
          const AiField(key: '合格区间', value: '160 – 220 mm'),
        ],
        verdict: '✓ 合格 · 落在标准区间内',
        verdictStatus: AiVerdictStatus.ok,
        actions: const [
          AiAction(label: '采纳入库', isPrimary: true),
          AiAction(label: '修正'),
        ],
      );
    }

    if (text.contains('扩展度')) {
      return ConversationItem(
        id: _uuid.v4(),
        type: ConversationItemType.aiCard,
        timestamp: time,
        aiLabel: 'AI',
        aiSubLabel: '结构化 · 需复核',
        fields: [
          const AiField(key: '指标', value: '扩展度'),
          const AiField(key: '实测', value: '545 mm'),
          const AiField(key: '单位', value: '未口述，已默认 mm', highlight: true),
        ],
        verdict: '! 请确认单位，或补充坍落度等级判定',
        verdictStatus: AiVerdictStatus.warn,
        actions: const [
          AiAction(label: '确认 mm', isPrimary: true),
          AiAction(label: '修正'),
        ],
      );
    }

    return ConversationItem(
      id: _uuid.v4(),
      type: ConversationItemType.aiCard,
      timestamp: time,
      aiLabel: 'AI',
      aiSubLabel: '已识别 · 上下文绑定',
      text: '已收到语音输入：$text',
    );
  }

  void pauseRecording() {
    if (state.value?.status != RecordingStatus.recording) return;
    _accumulated = state.value!.elapsed;
    _timer?.cancel();
    _transcribeTimer?.cancel();
    _audioSendTimer?.cancel();
    _audioCaptureService.stopRecording();
    _updateState((s) => s.copyWith(status: RecordingStatus.paused));
  }

  Future<void> resumeRecording() async {
    if (state.value?.status != RecordingStatus.paused) return;
    try {
      await _audioCaptureService.startRecording();
      _startTimer();
      _startTranscribeTimer();
      _startAudioSendTimer();
      _updateState((s) => s.copyWith(status: RecordingStatus.recording));
    } on Exception catch (e) {
      _updateState(
        (s) => s.copyWith(
          status: RecordingStatus.paused,
          errorMessage: '继续录音失败: $e',
        ),
      );
    }
  }

  void endRecording() {
    _updateState((s) => s.copyWith(status: RecordingStatus.ending));
  }

  Future<void> confirmEnd() async {
    _timer?.cancel();
    _transcribeTimer?.cancel();
    _audioSendTimer?.cancel();
    await _audioCaptureService.stopRecording();
    _webSocketService.disconnect();
    _updateState(
      (s) => s.copyWith(
        status: RecordingStatus.idle,
        elapsed: Duration.zero,
        items: [],
        isConnected: false,
      ),
    );
  }

  void cancelEnd() {
    _updateState(
      (s) => s.copyWith(
        status: s.isPaused ? RecordingStatus.paused : RecordingStatus.recording,
      ),
    );
  }

  void clearError() {
    _updateState((s) => s.copyWith(errorMessage: null));
  }

  void _updateState(RecordingState Function(RecordingState) update) {
    state = AsyncData(update(state.value ?? const RecordingState()));
  }
}
