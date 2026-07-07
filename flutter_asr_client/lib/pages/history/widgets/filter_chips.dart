import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/models/report.dart';
import 'package:asr_client/providers/report_providers.dart';
import 'package:asr_client/theme/app_colors.dart';

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(reportFilterProvider);
    final reports =
        ref.watch(reportGroupsProvider).expand((group) => group.reports);

    const configs = <_FilterConfig>[
      _FilterConfig(filter: ReportFilter.all, label: '全部', dotColor: null),
      _FilterConfig(filter: ReportFilter.ok, label: '合格', dotColor: AppColors.ok),
      _FilterConfig(filter: ReportFilter.warn, label: '预警', dotColor: AppColors.warn),
      _FilterConfig(filter: ReportFilter.draft, label: '草稿', dotColor: AppColors.ink3),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line2),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (final config in configs)
            Expanded(
              child: _FilterSegment(
                label: config.label,
                count: config.filter == ReportFilter.all
                    ? reports.length
                    : reports
                        .where((r) => _matches(config.filter, r.status))
                        .length,
                dotColor: config.dotColor,
                selected: config.filter == current,
                onTap: () =>
                    ref.read(reportFilterProvider.notifier).state = config.filter,
              ),
            ),
        ],
      ),
    );
  }

  bool _matches(ReportFilter filter, ReportStatus status) {
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
}

class _FilterConfig {
  const _FilterConfig({
    required this.filter,
    required this.label,
    required this.dotColor,
  });

  final ReportFilter filter;
  final String label;
  final Color? dotColor;
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    required this.label,
    required this.count,
    required this.selected,
    this.dotColor,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final Color? dotColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected ? (dotColor ?? AppColors.app) : Colors.transparent;
    final foreground = selected ? Colors.white : AppColors.ink2;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Colors.white : dotColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white70 : AppColors.ink3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
