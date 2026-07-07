import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/models/report.dart';
import 'package:asr_client/pages/history/widgets/date_group_header.dart';
import 'package:asr_client/pages/history/widgets/filter_chips.dart';
import 'package:asr_client/pages/history/widgets/report_preview_card.dart';
import 'package:asr_client/providers/report_providers.dart';
import 'package:asr_client/theme/app_colors.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(filteredReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text(
          '检测报告',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: const FilterChips(),
          ),
          Expanded(
            child: groups.isEmpty
                ? const _EmptyView()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                    itemCount: groups.length * 2,
                    itemBuilder: (context, index) {
                      final groupIndex = index ~/ 2;
                      final group = groups[groupIndex];
                      if (index.isEven) {
                        return DateGroupHeader(label: group.label);
                      }
                      return Column(
                        children: group.reports
                            .map((report) => _ReportCard(report: report))
                            .toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor, statusBg) = switch (report.status) {
      ReportStatus.ok => ('合格', AppColors.ok, AppColors.okBg),
      ReportStatus.warn => ('预警', AppColors.danger, AppColors.dangerBg),
      ReportStatus.draft => ('草稿', AppColors.ink3, AppColors.line),
    };

    return Card(
      color: AppColors.card,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(report.date),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.ink3),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              report.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              report.project,
              style: const TextStyle(fontSize: 12, color: AppColors.ink2),
            ),
            ReportPreviewCard(report: report),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 48, color: AppColors.ink3),
          SizedBox(height: 12),
          Text('该筛选条件下暂无报告', style: TextStyle(color: AppColors.ink3)),
        ],
      ),
    );
  }
}
