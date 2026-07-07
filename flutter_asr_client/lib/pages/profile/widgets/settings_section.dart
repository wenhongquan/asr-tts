import 'package:flutter/material.dart';
import 'package:asr_client/models/user_profile.dart';
import 'package:asr_client/pages/profile/widgets/settings_menu_item.dart';
import 'package:asr_client/theme/app_colors.dart';

class SettingsSectionWidget extends StatelessWidget {
  const SettingsSectionWidget({super.key, required this.section});

  final SettingsSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 6),
          child: Text(
            section.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.ink3,
              letterSpacing: 0.05,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: section.items
                .map((item) => SettingsMenuItem(item: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}
