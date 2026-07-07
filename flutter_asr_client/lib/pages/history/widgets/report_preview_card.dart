import 'package:flutter/material.dart';
import 'package:asr_client/models/report.dart';
import 'package:asr_client/theme/app_colors.dart';

class ReportPreviewCard extends StatelessWidget {
  const ReportPreviewCard({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.fields != null)
            ...report.fields!.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${field.key}: ',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.ink3,
                      ),
                    ),
                    Text(
                      field.value,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (report.verdict != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.okBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                report.verdict!,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ok,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
