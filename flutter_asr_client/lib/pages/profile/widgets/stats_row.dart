import 'package:flutter/material.dart';
import 'package:asr_client/models/user_profile.dart';
import 'package:asr_client/theme/app_colors.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          _StatCard(
            value: profile.monthlyCount.toString(),
            label: '本月检测',
            color: AppColors.app,
          ),
          const SizedBox(width: 10),
          _StatCard(value: profile.passRate, label: '合格率', color: AppColors.ok),
          const SizedBox(width: 10),
          _StatCard(
            value: profile.activeProjects.toString(),
            label: '进行中项目',
            color: AppColors.mid,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.ink3),
            ),
          ],
        ),
      ),
    );
  }
}
