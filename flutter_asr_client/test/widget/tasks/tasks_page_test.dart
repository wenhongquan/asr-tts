import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:asr_client/pages/tasks/tasks_page.dart';
import 'package:asr_client/services/mock_data_service.dart';

void main() {
  testWidgets('TasksPage displays task sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: const TasksPage())),
    );

    await tester.pumpAndSettle();

    final firstSection = MockDataService.taskSections.first;
    expect(find.text(firstSection.title), findsOneWidget);
    for (final task in firstSection.tasks) {
      expect(find.text(task.title), findsOneWidget);
    }
  });
}
