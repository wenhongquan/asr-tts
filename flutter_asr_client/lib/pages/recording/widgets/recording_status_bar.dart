import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:asr_client/theme/app_colors.dart';

class RecordingStatusBar extends StatelessWidget {
  const RecordingStatusBar({
    super.key,
    required this.isRecording,
    required this.elapsed,
    required this.audioLevel,
  });

  final bool isRecording;
  final Duration elapsed;
  final double audioLevel;

  String get _timerText {
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _PulsingDot(isRecording: isRecording),
          const SizedBox(width: 10),
          Text(
            _timerText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              letterSpacing: 1,
              color: AppColors.ink,
            ),
          ),
          const Spacer(),
          _Waveform(audioLevel: audioLevel),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.isRecording});

  final bool isRecording;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    if (widget.isRecording) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.danger,
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withValues(
                  alpha: widget.isRecording ? 0.3 * _animation.value : 0,
                ),
                blurRadius: 12 * _animation.value,
                spreadRadius: 4 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Waveform extends StatefulWidget {
  const _Waveform({required this.audioLevel});

  final double audioLevel;

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _baseHeights = <double>[8, 18, 12, 22, 10, 16, 7];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: List.generate(_baseHeights.length, (index) {
            final phase = _controller.value * 2 * math.pi + index * 0.8;
            final wave = math.sin(phase) * 4;
            final targetHeight =
                _baseHeights[index] + widget.audioLevel * 14 + wave;
            final clamped = targetHeight.clamp(4.0, 34.0);
            return _WaveBar(height: clamped);
          }),
        );
      },
    );
  }
}

class _WaveBar extends StatelessWidget {
  const _WaveBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    const maxHeight = 34.0;
    final scale = height / maxHeight;
    return Container(
      width: 3,
      height: maxHeight,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      alignment: Alignment.bottomCenter,
      child: Transform.scale(
        scaleY: scale,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 3,
          height: maxHeight,
          decoration: BoxDecoration(
            color: AppColors.app,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
