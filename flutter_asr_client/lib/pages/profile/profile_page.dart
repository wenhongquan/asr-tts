import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/pages/profile/widgets/profile_hero_card.dart';
import 'package:asr_client/pages/profile/widgets/server_settings_dialog.dart';
import 'package:asr_client/pages/profile/widgets/settings_section.dart';
import 'package:asr_client/pages/profile/widgets/stats_row.dart';
import 'package:asr_client/providers/profile_providers.dart';
import 'package:asr_client/services/mock_data_service.dart';
import 'package:asr_client/theme/app_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final settingsSections = MockDataService.settingsSections(
      () => _showServerDialog(context),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text(
          '我的',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.ink2),
            onPressed: () => _showServerDialog(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          ProfileHeroCard(profile: profile),
          StatsRow(profile: profile),
          ...settingsSections.map(
            (section) => SettingsSectionWidget(section: section),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showServerDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const ServerSettingsDialog());
  }
}
