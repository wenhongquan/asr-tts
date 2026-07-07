import 'package:flutter/material.dart';
import 'package:asr_client/theme/app_colors.dart';

class RecordingHeader extends StatelessWidget {
  const RecordingHeader({
    super.key,
    required this.projectName,
    required this.taskName,
    required this.templateName,
  });

  final String projectName;
  final String taskName;
  final String templateName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.nav, AppColors.nav2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            projectName,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7DB4E6),
              fontFamily: 'monospace',
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            taskName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            templateName,
            style: const TextStyle(fontSize: 12, color: Color(0xFFB8D3EA)),
          ),
        ],
      ),
    );
  }
}
