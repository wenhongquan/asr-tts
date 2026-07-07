import 'package:flutter/foundation.dart';

enum TaskStatus { recording, pending, scheduled, completed, failed }

@immutable
final class Task {
  const Task({
    required this.id,
    required this.title,
    required this.project,
    required this.status,
    this.progress,
    this.recordedCount,
    this.totalCount,
    this.footNote,
    this.timeInfo,
  });

  final String id;
  final String title;
  final String project;
  final TaskStatus status;
  final double? progress;
  final int? recordedCount;
  final int? totalCount;
  final String? footNote;
  final String? timeInfo;

  Task copyWith({
    String? id,
    String? title,
    String? project,
    TaskStatus? status,
    double? progress,
    int? recordedCount,
    int? totalCount,
    String? footNote,
    String? timeInfo,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      project: project ?? this.project,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      recordedCount: recordedCount ?? this.recordedCount,
      totalCount: totalCount ?? this.totalCount,
      footNote: footNote ?? this.footNote,
      timeInfo: timeInfo ?? this.timeInfo,
    );
  }
}

@immutable
final class TaskSection {
  const TaskSection({required this.title, required this.tasks, this.action});

  final String title;
  final List<Task> tasks;
  final String? action;
}
