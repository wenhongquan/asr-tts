import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asr_client/models/conversation.dart';
import 'package:asr_client/theme/app_colors.dart';

class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.item});

  final ConversationItem item;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(item.timestamp);

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
            boxShadow: [
              BoxShadow(
                color: AppColors.app.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.text ?? '',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFCFE4F6),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
