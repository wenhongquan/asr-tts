import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/services/mock_data_service.dart';
import 'package:asr_client/models/report.dart';

final reportGroupsProvider = Provider<List<ReportDateGroup>>(
  (_) => MockDataService.reportGroups,
);

final reportFilterProvider = StateProvider<ReportFilter>(
  (_) => ReportFilter.all,
);

enum ReportFilter { all, ok, warn, draft }

final filteredReportsProvider = Provider<List<ReportDateGroup>>((ref) {
  final groups = ref.watch(reportGroupsProvider);
  final filter = ref.watch(reportFilterProvider);

  if (filter == ReportFilter.all) return groups;

  return groups
      .map(
        (group) => ReportDateGroup(
          label: group.label,
          reports: group.reports
              .where((report) => _matchesFilter(report.status, filter))
              .toList(),
        ),
      )
      .where((group) => group.reports.isNotEmpty)
      .toList();
});

bool _matchesFilter(ReportStatus status, ReportFilter filter) {
  switch (filter) {
    case ReportFilter.ok:
      return status == ReportStatus.ok;
    case ReportFilter.warn:
      return status == ReportStatus.warn;
    case ReportFilter.draft:
      return status == ReportStatus.draft;
    case ReportFilter.all:
      return true;
  }
}
