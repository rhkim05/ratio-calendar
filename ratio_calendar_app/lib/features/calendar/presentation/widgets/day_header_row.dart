import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';

/// 요일/날짜 행 위젯
///
/// 캘린더 헤더 아래, 타임라인 위에 위치
/// 높이: AppSizes.dayHeaderHeight (72px)
///
/// - 요일: uppercase (MON, TUE, ...)
/// - 날짜: 숫자 (01, 02, ...)
/// - 오늘 날짜: primary color 원형 배경 + 흰색 텍스트
class DayHeaderRow extends StatelessWidget {
  const DayHeaderRow({
    super.key,
    required this.days,
    this.accentColor = AppColors.todayHighlight,
  });

  final List<DateTime> days;
  final Color accentColor;

  static const _dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.dayHeaderHeight,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 좌측 시간 컬럼 여백
          const SizedBox(width: AppSizes.timeColumnWidth),

          // 날짜 컬럼들
          ...days.map((date) => Expanded(
                child: _DayColumn(
                  dayName: _dayNames[date.weekday - 1],
                  dayNumber: date.day,
                  isToday: _isToday(date),
                  accentColor: accentColor,
                ),
              )),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.dayName,
    required this.dayNumber,
    required this.isToday,
    required this.accentColor,
  });

  final String dayName;
  final int dayNumber;
  final bool isToday;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 요일 라벨
        Text(
          dayName,
          style: AppTypography.dayLabel.copyWith(
            color: isToday ? accentColor : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.xs),

        // 날짜 숫자
        SizedBox(
          width: AppSizes.todayHighlightSize,
          height: AppSizes.todayHighlightSize,
          child: Container(
            decoration: isToday
                ? BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            alignment: Alignment.center,
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Text(
                dayNumber.toString(),
                style: AppTypography.dateNumber.copyWith(
                  color: isToday ? Colors.white : AppColors.textPrimary,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
