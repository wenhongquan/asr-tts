import 'package:flutter/foundation.dart';

enum ConversationItemType { userBubble, aiCard }

enum AiVerdictStatus { ok, warn, neutral }

@immutable
final class ConversationItem {
  const ConversationItem({
    required this.id,
    required this.type,
    required this.timestamp,
    this.text,
    this.aiLabel,
    this.aiSubLabel,
    this.fields = const [],
    this.verdict,
    this.verdictStatus = AiVerdictStatus.neutral,
    this.actions = const [],
  });

  final String id;
  final ConversationItemType type;
  final DateTime timestamp;
  final String? text;
  final String? aiLabel;
  final String? aiSubLabel;
  final List<AiField> fields;
  final String? verdict;
  final AiVerdictStatus verdictStatus;
  final List<AiAction> actions;

  ConversationItem copyWith({
    String? id,
    ConversationItemType? type,
    DateTime? timestamp,
    String? text,
    String? aiLabel,
    String? aiSubLabel,
    List<AiField>? fields,
    String? verdict,
    AiVerdictStatus? verdictStatus,
    List<AiAction>? actions,
  }) {
    return ConversationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
      aiLabel: aiLabel ?? this.aiLabel,
      aiSubLabel: aiSubLabel ?? this.aiSubLabel,
      fields: fields ?? this.fields,
      verdict: verdict ?? this.verdict,
      verdictStatus: verdictStatus ?? this.verdictStatus,
      actions: actions ?? this.actions,
    );
  }
}

@immutable
final class AiField {
  const AiField({
    required this.key,
    required this.value,
    this.highlight = false,
  });

  final String key;
  final String value;
  final bool highlight;
}

@immutable
final class AiAction {
  const AiAction({required this.label, this.isPrimary = false, this.onTap});

  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;
}
