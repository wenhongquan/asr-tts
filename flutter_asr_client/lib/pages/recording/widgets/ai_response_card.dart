import 'package:flutter/material.dart';
import 'package:asr_client/models/conversation.dart';
import 'package:asr_client/pages/recording/widgets/field_grid.dart';
import 'package:asr_client/pages/recording/widgets/verdict_badge.dart';
import 'package:asr_client/theme/app_colors.dart';

class AiResponseCard extends StatelessWidget {
  const AiResponseCard({super.key, required this.item});

  final ConversationItem item;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.aiBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ai,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.aiSubLabel ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: AppColors.ai,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.08,
                    ),
                  ),
                ],
              ),
              if (item.text != null) ...[
                const SizedBox(height: 7),
                Text(
                  item.text!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.ink2,
                    height: 1.4,
                  ),
                ),
              ],
              if (item.fields.isNotEmpty) FieldGrid(fields: item.fields),
              if (item.verdict != null) ...[
                const SizedBox(height: 6),
                VerdictBadge(
                  verdict: item.verdict!,
                  status: item.verdictStatus,
                ),
              ],
              if (item.actions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: item.actions
                      .map(
                        (action) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: action == item.actions.last ? 0 : 6,
                            ),
                            child: _MiniButton(action: action),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.action});

  final AiAction action;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: action.onTap,
      style: TextButton.styleFrom(
        backgroundColor: action.isPrimary ? AppColors.appBg : AppColors.card,
        foregroundColor: action.isPrimary ? AppColors.appDark : AppColors.ink2,
        padding: const EdgeInsets.symmetric(vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: action.isPrimary ? AppColors.appBg : AppColors.line2,
          ),
        ),
        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
      child: Text(action.label),
    );
  }
}
