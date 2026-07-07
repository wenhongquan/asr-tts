import 'package:flutter/material.dart';
import 'package:asr_client/models/report.dart';
import 'package:asr_client/pages/history/widgets/report_preview_card.dart';
import 'package:asr_client/theme/app_colors.dart';

class ReportItem extends StatefulWidget {
  const ReportItem({super.key, required this.report});

  final Report report;

  @override
  State<ReportItem> createState() => _ReportItemState();
}

class _ReportItemState extends State<ReportItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
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
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(14),
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
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.ink3,
                    size: 20,
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
              if (_expanded &&
                  (report.fields?.isNotEmpty ??
                      false || report.verdict != null))
                ReportPreviewCard(report: report),
            ],
          ),
        ),
      ),
    );
  }
}
