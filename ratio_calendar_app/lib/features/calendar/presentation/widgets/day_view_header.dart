import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';

/// Day View 전용 헤더 — 하루만 크게 표시
///
/// Stitch calendar_day 디자인 참고:
///   - 요일 풀네임: "WEDNESDAY" (uppercase, wide tracking)
///   - 날짜 숫자: "20" (33px, bold)
///   - 좌측 정렬 (timeColumnWidth 영역 아래)
///   - 오늘이면 todayHighlight 색상 적용
class DayViewHeader extends StatelessWidget {
  const DayViewHeader({
    super.key,
    required this.date,
  });

  final DateTime date;

  static const _dayNames = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final dayName = _dayNames[date.weekday - 1];

    return Container(
      height: AppSizes.dayHeaderHeight + 20, // 여유 공간 추가
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        left: AppSizes.md,
        bottom: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 요일 풀네임 (WEDNESDAY)
          Text(
            dayName,
            style: AppTypography.dayLabel.copyWith(
              color: isToday ? AppColors.todayHighlight : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.xs),

          // 날짜 숫자 (20)
          Text(
            date.day.toString(),
            style: AppTypography.dateNumber.copyWith(
              color: isToday ? AppColors.todayHighlight : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
