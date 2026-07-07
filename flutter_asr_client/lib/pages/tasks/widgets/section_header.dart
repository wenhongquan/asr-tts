import 'package:flutter/material.dart';
import 'package:asr_client/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const Spacer(),
          if (action != null)
            Text(
              action!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.app,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
