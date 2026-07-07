import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/services/mock_data_service.dart';
import 'package:asr_client/models/task.dart';

final taskSectionsProvider = Provider<List<TaskSection>>(
  (_) => MockDataService.taskSections,
);
