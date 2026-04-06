import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';

/// 캘린더 헤더 위젯
///
/// 구성:
///   - 좌측: 햄버거 메뉴 아이콘 (사이드 메뉴 열기)
///   - 중앙/좌측: 월/년도 텍스트 (ALL CAPS)
///   - 우측: 검색 + 오늘 캘린더 아이콘
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.currentDate,
    this.onMenuTap,
    this.onSearchTap,
    this.onTodayTap,
  });

  final DateTime currentDate;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onTodayTap;

  static const _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL',
    'MAY', 'JUNE', 'JULY', 'AUGUST',
    'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];

  @override
  Widget build(BuildContext context) {
    final monthYear = '${_months[currentDate.month - 1]} ${currentDate.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          // 햄버거 메뉴
          IconButton(
            onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, size: 24),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: AppSizes.sm),

          // 월/년도 (ALL CAPS)
          Expanded(
            child: Text(
              monthYear,
              style: AppTypography.monthTitle,
            ),
          ),

          // 검색 아이콘
          IconButton(
            onPressed: onSearchTap,
            icon: const Icon(Icons.search, size: 24),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          // 오늘 캘린더 아이콘
          IconButton(
            onPressed: onTodayTap,
            icon: const Icon(Icons.today, size: 24),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}
