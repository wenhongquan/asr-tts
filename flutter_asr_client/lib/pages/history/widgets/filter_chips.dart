import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/providers/report_providers.dart';
import 'package:asr_client/theme/app_colors.dart';

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(reportFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportFilter.values.map((filter) {
          final isSelected = filter == current;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_label(filter)),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(reportFilterProvider.notifier).state = filter,
              selectedColor: AppColors.app,
              backgroundColor: AppColors.card,
              side: BorderSide(
                color: isSelected ? AppColors.app : AppColors.line2,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.ink2,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(ReportFilter filter) {
    return switch (filter) {
      ReportFilter.all => '全部',
      ReportFilter.ok => '合格',
      ReportFilter.warn => '预警',
      ReportFilter.draft => '草稿',
    };
  }
}
