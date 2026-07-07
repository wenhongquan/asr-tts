import 'package:flutter/material.dart';
import 'package:asr_client/models/user_profile.dart';
import 'package:asr_client/theme/app_colors.dart';

class SettingsMenuItem extends StatelessWidget {
  const SettingsMenuItem({super.key, required this.item});

  final SettingsItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: item.iconBgColor ?? AppColors.bg,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(item.icon, style: const TextStyle(fontSize: 16)),
        ),
      ),
      title: Text(
        item.label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.value != null)
            Text(
              item.value!,
              style: const TextStyle(fontSize: 12, color: AppColors.ink3),
            ),
          if (item.showArrow) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.ink3, size: 20),
          ],
        ],
      ),
      onTap: item.onTap,
    );
  }
}
