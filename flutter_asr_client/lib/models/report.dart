import 'package:flutter/foundation.dart';

enum ReportStatus { ok, warn, draft }

@immutable
final class Report {
  const Report({
    required this.id,
    required this.name,
    required this.project,
    required this.status,
    required this.date,
    this.reportId,
    this.fields,
    this.verdict,
  });

  final String id;
  final String name;
  final String project;
  final ReportStatus status;
  final DateTime date;
  final String? reportId;
  final List<ReportField>? fields;
  final String? verdict;

  Report copyWith({
    String? id,
    String? name,
    String? project,
    ReportStatus? status,
    DateTime? date,
    String? reportId,
    List<ReportField>? fields,
    String? verdict,
  }) {
    return Report(
      id: id ?? this.id,
      name: name ?? this.name,
      project: project ?? this.project,
      status: status ?? this.status,
      date: date ?? this.date,
      reportId: reportId ?? this.reportId,
      fields: fields ?? this.fields,
      verdict: verdict ?? this.verdict,
    );
  }
}

@immutable
final class ReportField {
  const ReportField({required this.key, required this.value});

  final String key;
  final String value;
}

@immutable
final class ReportDateGroup {
  const ReportDateGroup({required this.label, required this.reports});

  final String label;
  final List<Report> reports;
}
