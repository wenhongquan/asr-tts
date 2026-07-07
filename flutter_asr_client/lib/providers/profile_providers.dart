import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/services/mock_data_service.dart';
import 'package:asr_client/models/user_profile.dart';

final userProfileProvider = Provider<UserProfile>(
  (_) => MockDataService.userProfile,
);

final settingsSectionsProvider = Provider<List<SettingsSection>>(
  (_) => MockDataService.settingsSections(null),
);
