import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/core/router/app_router.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:ratio_calendar/features/settings/presentation/providers/settings_providers.dart';

/// 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더: ← + SETTINGS ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.xs,
                vertical: AppSizes.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'SETTINGS',
                    style: AppTypography.headline.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── 스크롤 가능한 설정 목록 ──
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── GENERAL ──
                  const _SectionHeader(title: 'GENERAL'),
                  _SettingRow(
                    label: 'Default View',
                    value: _viewLabel(settings.defaultView),
                    hasChevron: true,
                    onTap: () => _showOptionPicker(
                      context: context,
                      title: 'Default View',
                      options: ['Day', '3-Day', 'Month'],
                      selected: _viewLabel(settings.defaultView),
                      onSelected: (v) => notifier.setDefaultView(_parseView(v)),
                    ),
                  ),
                  _SettingRow(
                    label: 'Start of Week',
                    value: settings.startOfWeek.label,
                    hasChevron: true,
                    onTap: () => _showOptionPicker(
                      context: context,
                      title: 'Start of Week',
                      options: StartOfWeek.values.map((e) => e.label).toList(),
                      selected: settings.startOfWeek.label,
                      onSelected: (v) => notifier.setStartOfWeek(
                        StartOfWeek.values.firstWhere((e) => e.label == v),
                      ),
                    ),
                  ),
                  const _SettingRow(
                    label: 'Time Zone',
                    value: 'Auto (GMT+9)',
                    trailing: Icon(
                      Icons.language,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const _SectionDivider(),

                  // ── NOTIFICATIONS ──
                  const _SectionHeader(title: 'NOTIFICATIONS'),
                  _SettingRow(
                    label: 'Event Reminders',
                    trailing: CupertinoSwitch(
                      value: settings.eventReminders,
                      activeTrackColor: AppColors.textPrimary,
                      onChanged: notifier.setEventReminders,
                    ),
                  ),
                  _SettingRow(
                    label: 'Default Reminder Time',
                    value: _alertLabel(settings.defaultReminderTime),
                    hasChevron: true,
                    onTap: () => _showOptionPicker(
                      context: context,
                      title: 'Default Reminder Time',
                      options: [
                        'None',
                        '5 minutes before',
                        '15 minutes before',
                        '30 minutes before',
                        '1 hour before',
                        '1 day before',
                      ],
                      selected: _alertLabel(settings.defaultReminderTime),
                      onSelected: (v) =>
                          notifier.setDefaultReminderTime(_parseAlert(v)),
                    ),
                  ),
                  _SettingRow(
                    label: 'Daily Agenda',
                    subtitle: 'Receive a daily summary each morning',
                    trailing: CupertinoSwitch(
                      value: settings.dailyAgenda,
                      activeTrackColor: AppColors.textPrimary,
                      onChanged: notifier.setDailyAgenda,
                    ),
                  ),
                  const _SectionDivider(),

                  // ── APPEARANCE ──
                  const _SectionHeader(title: 'APPEARANCE'),
                  _SettingRow(
                    label: 'Theme',
                    value: 'Light',
                    trailing: const Icon(
                      Icons.light_mode,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Accent Color 행
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm + 2,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Accent Color',
                            style: AppTypography.body,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            accentColorOptions.length,
                            (i) {
                              final isSelected =
                                  i == settings.accentColorIndex;
                              return GestureDetector(
                                onTap: () => notifier.setAccentColorIndex(i),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                    color: accentColorOptions[i].withValues(
                                      alpha: isSelected ? 1.0 : 0.35,
                                    ),
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: accentColorOptions[i],
                                            width: 2.5,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _SectionDivider(),

                  // ── ACCOUNT ──
                  const _SectionHeader(title: 'ACCOUNT'),
                  Builder(
                    builder: (context) {
                      final isLoggedIn = ref.watch(isLoggedInProvider);
                      final user = ref.watch(currentUserProvider);

                      if (isLoggedIn && user != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SettingRow(
                              label: 'Email',
                              value: user.email,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm + 2,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  ref.read(authProvider.notifier).signOut();
                                },
                                child: Text(
                                  'Sign Out',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.work,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.sm + 2,
                        ),
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.login),
                          child: Text(
                            'Sign In',
                            style: AppTypography.body.copyWith(
                              color: AppColors.personal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // ── APP VERSION ──
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSizes.xxl,
                      bottom: AppSizes.lg,
                    ),
                    child: Center(
                      child: Text(
                        'APP VERSION  1.0.0',
                        style: AppTypography.sectionLabel.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  String _viewLabel(CalendarViewType type) => switch (type) {
        CalendarViewType.day => 'Day',
        CalendarViewType.threeDay => '3-Day',
        CalendarViewType.month => 'Month',
        _ => '3-Day',
      };

  CalendarViewType _parseView(String label) => switch (label) {
        'Day' => CalendarViewType.day,
        '3-Day' => CalendarViewType.threeDay,
        'Month' => CalendarViewType.month,
        _ => CalendarViewType.threeDay,
      };

  String _alertLabel(AlertType type) => switch (type) {
        AlertType.none => 'None',
        AlertType.fiveMinutes => '5 minutes before',
        AlertType.fifteenMinutes => '15 minutes before',
        AlertType.thirtyMinutes => '30 minutes before',
        AlertType.oneHour => '1 hour before',
        AlertType.oneDay => '1 day before',
      };

  AlertType _parseAlert(String label) => switch (label) {
        'None' => AlertType.none,
        '5 minutes before' => AlertType.fiveMinutes,
        '15 minutes before' => AlertType.fifteenMinutes,
        '30 minutes before' => AlertType.thirtyMinutes,
        '1 hour before' => AlertType.oneHour,
        '1 day before' => AlertType.oneDay,
        _ => AlertType.fifteenMinutes,
      };

  void _showOptionPicker({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSheet),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.md,
              ),
              child: Text(title, style: AppTypography.headline),
            ),
            ...options.map((option) {
              final isActive = option == selected;
              return InkWell(
                onTap: () {
                  onSelected(option);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: AppTypography.body.copyWith(
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (isActive)
                        const Icon(
                          Icons.check,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}

// ── Private Widgets ──

/// 섹션 타이틀
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md, AppSizes.lg, AppSizes.md, AppSizes.sm,
      ),
      child: Text(title, style: AppTypography.sectionLabel),
    );
  }
}

/// 섹션 구분선
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.divider,
      height: 1,
      indent: AppSizes.md,
      endIndent: AppSizes.md,
    );
  }
}

/// 설정 행: 라벨 + 값/trailing 위젯
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    this.value,
    this.subtitle,
    this.trailing,
    this.hasChevron = false,
    this.onTap,
  });

  final String label;
  final String? value;
  final String? subtitle;
  final Widget? trailing;
  final bool hasChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 14,
        ),
        child: Row(
          children: [
            // 왼쪽: 라벨 + 부제
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.body),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 오른쪽: 값 텍스트 + chevron 또는 trailing 위젯
            if (trailing != null)
              trailing!
            else if (value != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (hasChevron) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
