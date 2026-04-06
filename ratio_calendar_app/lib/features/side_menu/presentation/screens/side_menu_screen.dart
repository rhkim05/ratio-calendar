import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/core/router/app_router.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';

/// 사이드 메뉴 — 좌측 Drawer
///
/// Stitch side_menu 디자인 참고:
///   - 프로필 헤더 (워크스페이스 이름 + 이메일)
///   - 뷰 전환: DAY / 3-DAY / MONTH
///   - CALENDARS: Personal(blue), Work(red), Shared(green)
///   - SETTINGS (하단)
class SideMenuScreen extends ConsumerWidget {
  const SideMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentView = ref.watch(currentViewTypeProvider);

    return Drawer(
      width: AppSizes.sideMenuWidth,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 프로필 헤더 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.lg, AppSizes.md, AppSizes.lg,
              ),
              child: Row(
                children: [
                  // 아바타
                  Container(
                    width: AppSizes.avatarMedium,
                    height: AppSizes.avatarMedium,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighest,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Architect Workspace',
                          style: AppTypography.eventTitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'precision@calendar.so',
                          style: AppTypography.eventTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 뷰 전환 옵션 ──
            _ViewOption(
              icon: Icons.calendar_view_day,
              label: 'DAY',
              isSelected: currentView == CalendarViewType.day,
              onTap: () {
                ref.read(currentViewTypeProvider.notifier).change(CalendarViewType.day);
                Navigator.of(context).pop();
              },
            ),
            _ViewOption(
              icon: Icons.calendar_view_week,
              label: '3-DAY',
              isSelected: currentView == CalendarViewType.threeDay,
              onTap: () {
                ref.read(currentViewTypeProvider.notifier).change(CalendarViewType.threeDay);
                Navigator.of(context).pop();
              },
            ),
            _ViewOption(
              icon: Icons.calendar_month,
              label: 'MONTH',
              isSelected: currentView == CalendarViewType.month,
              onTap: () {
                ref.read(currentViewTypeProvider.notifier).change(CalendarViewType.month);
                Navigator.of(context).pop();
              },
            ),

            const SizedBox(height: AppSizes.lg),

            // ── CALENDARS 섹션 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text(
                'CALENDARS',
                style: AppTypography.sectionLabel,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            _CalendarItem(
              color: AppColors.personal,
              label: 'Personal',
              isEnabled: true,
            ),
            _CalendarItem(
              color: AppColors.work,
              label: 'Work',
              isEnabled: true,
            ),
            _CalendarItem(
              color: AppColors.shared,
              label: 'Shared',
              isEnabled: true,
            ),

            const Spacer(),

            // ── SETTINGS ──
            Divider(
              color: AppColors.divider,
              height: 1,
            ),
            _ViewOption(
              icon: Icons.settings_outlined,
              label: 'SETTINGS',
              isSelected: false,
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.settings);
              },
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }
}

/// 뷰 전환 옵션 아이템
class _ViewOption extends StatelessWidget {
  const _ViewOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        color: isSelected ? AppColors.surface : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.sm + AppSizes.xs),
            Text(
              label,
              style: AppTypography.dayLabel.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 캘린더 아이템 (색상 dot + 이름)
class _CalendarItem extends StatelessWidget {
  const _CalendarItem({
    required this.color,
    required this.label,
    required this.isEnabled,
  });

  final Color color;
  final String label;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: 캘린더 토글 구현
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.calendarDotSize,
              height: AppSizes.calendarDotSize,
              decoration: BoxDecoration(
                color: isEnabled ? color : AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.sm + AppSizes.xs),
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
