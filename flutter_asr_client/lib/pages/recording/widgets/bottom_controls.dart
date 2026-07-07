import 'package:flutter/material.dart';
import 'package:asr_client/pages/recording/notifiers/recording_notifier.dart';
import 'package:asr_client/theme/app_colors.dart';

class BottomControls extends StatelessWidget {
  const BottomControls({
    super.key,
    required this.status,
    required this.elapsed,
    required this.audioLevel,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  final RecordingStatus status;
  final Duration elapsed;
  final double audioLevel;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  String get _timerText {
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = status == RecordingStatus.paused;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer + waveform row
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPaused ? AppColors.warn : AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _timerText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isPaused ? Icons.mic_off : Icons.mic,
                    size: 16,
                    color: AppColors.ink2,
                  ),
                ],
              ),
            ),
            // Button row
            Row(
              children: [
                Expanded(
                  flex: 44,
                  child: _ScaleButton(
                    onTap: isPaused ? onResume : onPause,
                    child: ElevatedButton(
                      onPressed: isPaused ? onResume : onPause,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.card,
                        foregroundColor: AppColors.ink2,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: AppColors.line2,
                            width: 1.5,
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(isPaused ? '▶ 继续' : '⏸ 暂停'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 56,
                  child: _ScaleButton(
                    onTap: onEnd,
                    child: ElevatedButton(
                      onPressed: onEnd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('■ 结束并生成报告'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleButton extends StatefulWidget {
  const _ScaleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
