import 'package:flutter/material.dart';
import 'package:asr_client/models/task.dart';
import 'package:asr_client/theme/app_colors.dart';

class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      TaskStatus.recording => ('录制中', AppColors.appBg, AppColors.appDark),
      TaskStatus.pending => ('待检测', AppColors.warnBg, const Color(0xFF8A6D00)),
      TaskStatus.scheduled => ('已排期', AppColors.midBg, const Color(0xFF1C7A6D)),
      TaskStatus.completed => ('已完成', AppColors.okBg, AppColors.ok),
      TaskStatus.failed => ('异常', AppColors.dangerBg, AppColors.danger),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
