import 'package:flutter/material.dart';
import 'package:asr_client/models/conversation.dart';
import 'package:asr_client/pages/recording/widgets/user_bubble.dart';
import 'package:asr_client/theme/app_colors.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({
    super.key,
    required this.items,
    this.liveUtterance,
    required this.isRecording,
  });

  final List<ConversationItem> items;
  final String? liveUtterance;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: UserBubble(key: ValueKey(item.id), item: item),
          ),
        if (liveUtterance != null && liveUtterance!.trim().isNotEmpty)
          _LiveBubble(text: liveUtterance!, isRecording: isRecording),
      ],
    );
  }
}

class _LiveBubble extends StatelessWidget {
  const _LiveBubble({required this.text, required this.isRecording});

  final String text;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.app,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              if (isRecording) ...[
                const SizedBox(width: 6),
                const _PulsingDots(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
      builder: (_, child) {
        return Opacity(
          opacity: _controller.value < 0.5 ? 0.3 : 1.0,
          child: child,
        );
      },
      child: const Text(
        '● ● ●',
        style: TextStyle(fontSize: 6, color: Colors.white70, letterSpacing: 2),
      ),
    );
  }
}
