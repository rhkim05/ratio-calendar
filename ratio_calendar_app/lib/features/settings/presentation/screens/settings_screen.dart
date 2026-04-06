import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/router/app_router.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/auth/presentation/providers/auth_providers.dart';

/// 설정 화면
///
/// Stitch settings_screen 디자인 참고:
///   - GENERAL: Default View, Start of Week, Time Zone
///   - NOTIFICATIONS: Event Reminders (토글), Default Reminder Time, Daily Agenda (토글)
///   - APPEARANCE: Theme, Accent Color (색상 원형 버튼)
///   - ACCOUNT: Email / Sign Out (미로그인 시 Sign In)
///   - 하단: APP VERSION 1.0.0
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // UI-only state (기능 연결은 다음 단계)
  String _defaultView = '3-Day';
  String _startOfWeek = 'Sunday';
  bool _eventReminders = true;
  String _defaultReminderTime = '15 minutes before';
  bool _dailyAgenda = false;
  String _theme = 'Light';
  int _selectedAccentIndex = 0;

  static const _accentColors = [
    AppColors.personal,    // Blue
    AppColors.work,        // Red
    AppColors.shared,      // Green
    Color(0xFFFFCC00),     // Yellow
    Color(0xFFAF52DE),     // Purple
  ];

  @override
  Widget build(BuildContext context) {
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
                  _SectionHeader(title: 'GENERAL'),
                  _SettingRow(
                    label: 'Default View',
                    value: _defaultView,
                    hasChevron: true,
                    onTap: () => _showOptionPicker(
                      title: 'Default View',
                      options: ['Day', '3-Day', 'Month'],
                      selected: _defaultView,
                      onSelected: (v) => setState(() => _defaultView = v),
                    ),
                  ),
                  _SettingRow(
                    label: 'Start of Week',
                    value: _startOfWeek,
                    hasChevron: true,
                    onTap: () => _showOptionPicker(
                      title: 'Start of Week',
                      options: ['Sunday', 'Monday', 'Saturday'],
                      selected: _startOfWeek,
                      onSelected: (v) => setState(() => _startOfWeek = v),
                    ),
                  ),
                  _SettingRow(
                    label: 'Time Zone',
                    value: 'Auto (GMT+9)',
                    trailing: const Icon(
                      Icons.language,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const _SectionDivider(),

                  // ── NOTIFICATIONS ──
                  _SectionHeader(title: 'NOTIFICATIONS'),
                  _SettingRow(
                    label: 'Event Reminders',
                    trailing: CupertinoSwitch(
                      value: _eventReminders,
                      activeTrackColor: AppColors.textPrimary,
                      onChanged: (v) => setState(() => _eventReminders = v),
                    ),
                  ),
                  _SettingRow(
                    label: 'Default Reminder Time',
                    value: _defaultReminderTime,
                    hasChevron: true,
                    onTap: () => _showOptionPicker(
                      title: 'Default Reminder Time',
                      options: [
                        '5 minutes before',
                        '10 minutes before',
                        '15 minutes before',
                        '30 minutes before',
                        '1 hour before',
                      ],
                      selected: _defaultReminderTime,
                      onSelected: (v) =>
                          setState(() => _defaultReminderTime = v),
                    ),
                  ),
                  _SettingRow(
                    label: 'Daily Agenda',
                    subtitle: 'Receive a daily summary each morning',
                    trailing: CupertinoSwitch(
                      value: _dailyAgenda,
                      activeTrackColor: AppColors.textPrimary,
                      onChanged: (v) => setState(() => _dailyAgenda = v),
                    ),
                  ),
                  const _SectionDivider(),

                  // ── APPEARANCE ──
                  _SectionHeader(title: 'APPEARANCE'),
                  _SettingRow(
                    label: 'Theme',
                    value: _theme,
                    trailing: Icon(
                      _theme == 'Light' ? Icons.light_mode : Icons.dark_mode,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () => _showOptionPicker(
                      title: 'Theme',
                      options: ['Light'],
                      selected: _theme,
                      onSelected: (v) => setState(() => _theme = v),
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
                          children: List.generate(_accentColors.length, (i) {
                            final isSelected = i == _selectedAccentIndex;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAccentIndex = i),
                              child: Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: _accentColors[i].withValues(
                                    alpha: isSelected ? 1.0 : 0.35,
                                  ),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: _accentColors[i],
                                          width: 2.5,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const _SectionDivider(),

                  // ── ACCOUNT ──
                  _SectionHeader(title: 'ACCOUNT'),
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

  /// 옵션 선택 바텀 시트
  void _showOptionPicker({
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
