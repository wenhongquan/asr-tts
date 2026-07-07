import 'package:flutter/material.dart';
import 'package:asr_client/models/conversation.dart';
import 'package:asr_client/theme/app_colors.dart';

class VerdictBadge extends StatelessWidget {
  const VerdictBadge({super.key, required this.verdict, required this.status});

  final String verdict;
  final AiVerdictStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      AiVerdictStatus.ok => (AppColors.okBg, AppColors.ok),
      AiVerdictStatus.warn => (AppColors.dangerBg, AppColors.danger),
      AiVerdictStatus.neutral => (AppColors.bg, AppColors.ink3),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        verdict,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
