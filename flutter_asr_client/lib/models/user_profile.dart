import 'package:flutter/material.dart';

@immutable
final class UserProfile {
  const UserProfile({
    required this.name,
    required this.role,
    required this.employeeId,
    required this.avatarText,
    required this.monthlyCount,
    required this.passRate,
    required this.activeProjects,
  });

  final String name;
  final String role;
  final String employeeId;
  final String avatarText;
  final int monthlyCount;
  final String passRate;
  final int activeProjects;

  UserProfile copyWith({
    String? name,
    String? role,
    String? employeeId,
    String? avatarText,
    int? monthlyCount,
    String? passRate,
    int? activeProjects,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      avatarText: avatarText ?? this.avatarText,
      monthlyCount: monthlyCount ?? this.monthlyCount,
      passRate: passRate ?? this.passRate,
      activeProjects: activeProjects ?? this.activeProjects,
    );
  }
}

@immutable
final class SettingsSection {
  const SettingsSection({required this.title, required this.items});

  final String title;
  final List<SettingsItem> items;
}

@immutable
final class SettingsItem {
  const SettingsItem({
    required this.icon,
    required this.label,
    this.iconBgColor,
    this.iconColor,
    this.value,
    this.showArrow = true,
    this.onTap,
  });

  final String icon;
  final String label;
  final Color? iconBgColor;
  final Color? iconColor;
  final String? value;
  final bool showArrow;
  final VoidCallback? onTap;
}
