import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:asr_client/models/task.dart';
import 'package:asr_client/pages/tasks/widgets/task_status_chip.dart';
import 'package:asr_client/theme/app_colors.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: () => context.go('/recording'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TaskStatusChip(status: task.status),
                  const Spacer(),
                  if (task.timeInfo != null)
                    Text(
                      task.timeInfo!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.ink3,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                task.project,
                style: const TextStyle(fontSize: 12, color: AppColors.ink2),
              ),
              if (task.status == TaskStatus.recording &&
                  task.progress != null) ...[
                const SizedBox(height: 12),
                _ProgressBar(progress: task.progress!),
              ],
              if (task.footNote != null) ...[
                const SizedBox(height: 9),
                Text(
                  task.footNote!,
                  style: const TextStyle(fontSize: 11, color: AppColors.ink3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clamped,
            backgroundColor: AppColors.line,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.app),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${(clamped * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.appDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
