import 'package:flutter/material.dart';
import 'package:asr_client/models/conversation.dart';
import 'package:asr_client/theme/app_colors.dart';

class FieldGrid extends StatelessWidget {
  const FieldGrid({super.key, required this.fields});

  final List<AiField> fields;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        children: fields
            .map(
              (field) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        field.key,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink3,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        field.value,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: field.highlight
                              ? AppColors.warn
                              : AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
