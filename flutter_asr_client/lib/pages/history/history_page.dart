import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/pages/history/widgets/date_group_header.dart';
import 'package:asr_client/pages/history/widgets/filter_chips.dart';
import 'package:asr_client/pages/history/widgets/report_item.dart';
import 'package:asr_client/providers/report_providers.dart';
import 'package:asr_client/theme/app_colors.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

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
          '检测记录',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.ink2),
            onPressed: () {},
          ),
        ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: groups.length * 2,
                    itemBuilder: (context, index) {
                      final groupIndex = index ~/ 2;
                      final group = groups[groupIndex];
                      if (index.isEven) {
                        return DateGroupHeader(label: group.label);
                      }
                      return Column(
                        children: group.reports
                            .map((report) => ReportItem(report: report))
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 48, color: AppColors.ink3),
          SizedBox(height: 12),
          Text('该筛选条件下暂无记录', style: TextStyle(color: AppColors.ink3)),
        ],
      ),
    );
  }
}
