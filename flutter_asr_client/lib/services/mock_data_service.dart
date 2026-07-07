import 'package:flutter/material.dart';
import 'package:asr_client/models/task.dart';
import 'package:asr_client/models/report.dart';
import 'package:asr_client/models/user_profile.dart';
import 'package:asr_client/theme/app_colors.dart';

abstract final class MockDataService {
  static const userProfile = UserProfile(
    name: '陈志远',
    role: '试验检测员',
    employeeId: 'T-0417',
    avatarText: '陈',
    monthlyCount: 128,
    passRate: '96%',
    activeProjects: 4,
  );

  static final taskSections = [
    const TaskSection(
      title: '进行中',
      tasks: [
        Task(
          id: 't1',
          title: '混凝土坍落度试验',
          project: 'G15 沈海高速 · K1120+300',
          status: TaskStatus.recording,
          progress: 0.6,
          recordedCount: 3,
          totalCount: 5,
          footNote: '3 / 5 指标已录',
          timeInfo: '02:47',
        ),
      ],
    ),
    const TaskSection(
      title: '待检测',
      tasks: [
        Task(
          id: 't2',
          title: '钢筋原材拉伸试验',
          project: 'G15 沈海高速 · 钢筋进场批 B-0712',
          status: TaskStatus.pending,
          footNote: '指标模板 · 屈服/抗拉/伸长率',
          timeInfo: '今日截止',
        ),
        Task(
          id: 't3',
          title: '路基压实度检测',
          project: '越南 河内-海防高速 · 第 3 标段',
          status: TaskStatus.pending,
          footNote: '灌砂法 · 3 个测点',
          timeInfo: '今日',
        ),
        Task(
          id: 't4',
          title: '水泥胶砂强度',
          project: 'G15 沈海高速 · 水泥进场',
          status: TaskStatus.scheduled,
          footNote: '28d 龄期 · 抗压',
          timeInfo: '明日',
        ),
      ],
    ),
    const TaskSection(
      title: '今日已完成',
      tasks: [
        Task(
          id: 't5',
          title: '沥青混合料马歇尔试验',
          project: 'G15 沈海高速 · 面层 AC-20',
          status: TaskStatus.completed,
          footNote: '报告已生成',
          timeInfo: '08:52',
        ),
      ],
    ),
  ];

  static final reportGroups = [
    ReportDateGroup(
      label: '今天',
      reports: [
        Report(
          id: 'r1',
          name: '沥青混合料马歇尔试验',
          project: 'G15 沈海 · 08:52 · 报告 R-2071',
          status: ReportStatus.ok,
          date: DateTime.now(),
          reportId: 'R-2071',
          fields: const [
            ReportField(key: '检测项', value: '马歇尔稳定度'),
            ReportField(key: '稳定度', value: '8.6 kN（≥8.0）'),
            ReportField(key: '流值', value: '3.2 mm（2–4）'),
            ReportField(key: '空隙率', value: '4.1 %（3–6）'),
          ],
          verdict: '✓ 各项合格',
        ),
        Report(
          id: 'r2',
          name: '混凝土抗压强度（试块）',
          project: 'G15 沈海 · 08:10 · 报告 R-2070',
          status: ReportStatus.warn,
          date: DateTime.now(),
          reportId: 'R-2070',
        ),
      ],
    ),
    ReportDateGroup(
      label: '昨天',
      reports: [
        Report(
          id: 'r3',
          name: '路基压实度检测',
          project: '越南河内-海防 · 16:30 · R-2065',
          status: ReportStatus.ok,
          date: DateTime.now().subtract(const Duration(days: 1)),
          reportId: 'R-2065',
        ),
        Report(
          id: 'r4',
          name: '钢筋原材拉伸试验',
          project: 'G15 沈海 · 14:02 · 草稿未定稿',
          status: ReportStatus.draft,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Report(
          id: 'r5',
          name: '水泥胶砂强度 28d',
          project: 'G15 沈海 · 10:20 · R-2061',
          status: ReportStatus.ok,
          date: DateTime.now().subtract(const Duration(days: 1)),
          reportId: 'R-2061',
        ),
      ],
    ),
  ];

  static List<SettingsSection> settingsSections(VoidCallback? onServerTap) => [
    SettingsSection(
      title: '采集设置',
      items: [
        SettingsItem(
          icon: '🎙️',
          label: '语音输入与麦克风',
          iconBgColor: AppColors.appBg,
          iconColor: AppColors.appDark,
        ),
        SettingsItem(
          icon: '🔤',
          label: '工程术语热词表',
          iconBgColor: AppColors.aiBg,
          iconColor: AppColors.ai,
          value: '已启用',
        ),
        SettingsItem(
          icon: '📥',
          label: '离线暂存与补传',
          iconBgColor: AppColors.warnBg,
          iconColor: const Color(0xFF8A6D00),
          value: '2 条待传',
        ),
      ],
    ),
    SettingsSection(
      title: '我的工作',
      items: [
        SettingsItem(
          icon: '🗂️',
          label: '我负责的项目',
          iconBgColor: AppColors.midBg,
          iconColor: const Color(0xFF1C7A6D),
          value: '4',
        ),
        SettingsItem(
          icon: '📊',
          label: '我的检测统计',
          iconBgColor: AppColors.okBg,
          iconColor: AppColors.ok,
        ),
      ],
    ),
    SettingsSection(
      title: '账户',
      items: [
        SettingsItem(
          icon: '🔔',
          label: '消息与告警',
          iconBgColor: AppColors.bg,
          iconColor: AppColors.ink2,
        ),
        SettingsItem(
          icon: '🛡️',
          label: '账号与安全',
          iconBgColor: AppColors.bg,
          iconColor: AppColors.ink2,
        ),
        SettingsItem(
          icon: '⎋',
          label: '退出登录',
          iconBgColor: AppColors.dangerBg,
          iconColor: AppColors.danger,
        ),
      ],
    ),
  ];
}
