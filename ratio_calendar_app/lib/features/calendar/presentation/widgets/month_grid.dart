import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 월 달력 그리드 위젯
///
/// Stitch calendar_month 디자인 참고:
///   - 요일 행: S M T W T F S (single letter, wide tracking)
///   - 날짜 셀: 숫자, 이전/다음 달은 연한 색
///   - 오늘: #003049 둥근 정사각형 배경 + 흰색 텍스트
///   - 이벤트 있는 날: 하단에 색상 도트 (최대 3개)
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.eventsByDay,
    required this.calendarColors,
    required this.onDateTap,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Map<String, List<EventEntity>> eventsByDay;
  final Map<String, Color> calendarColors;
  final void Function(DateTime date) onDateTap;

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// 그리드에 표시할 날짜 목록 (이전 달 padding + 현재 달 + 다음 달 padding)
  List<DateTime> _buildGridDates() {
    final firstOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;

    // 일요일 시작 (weekday: 1=Mon ~ 7=Sun → 일요일=7 → offset 0)
    final startWeekday = firstOfMonth.weekday % 7; // Sun=0, Mon=1, ...

    final dates = <DateTime>[];

    // 이전 달 날짜
    for (var i = startWeekday - 1; i >= 0; i--) {
      dates.add(firstOfMonth.subtract(Duration(days: i + 1)));
    }

    // 현재 달 날짜
    for (var d = 1; d <= daysInMonth; d++) {
      dates.add(DateTime(displayedMonth.year, displayedMonth.month, d));
    }

    // 다음 달 날짜 (6주 = 42칸 채우기)
    while (dates.length < 42) {
      dates.add(DateTime(
        displayedMonth.year,
        displayedMonth.month,
        daysInMonth + (dates.length - startWeekday - daysInMonth) + 1,
      ));
    }

    // 마지막 행이 모두 다음달이면 제거 (5주면 충분)
    if (dates.length > 35) {
      final lastRowStart = dates.length - 7;
      final allNextMonth = dates
          .sublist(lastRowStart)
          .every((d) => d.month != displayedMonth.month);
      if (allNextMonth) {
        dates.removeRange(lastRowStart, dates.length);
      }
    }

    return dates;
  }

  /// 날짜에 해당하는 이벤트의 고유 색상 목록 (최대 3개)
  List<Color> _eventDotsForDate(DateTime date) {
    final events = eventsByDay[_dateKey(date)];
    if (events == null || events.isEmpty) return [];

    final colors = <Color>{};
    for (final event in events) {
      final color = calendarColors[event.calendarId];
      if (color != null) colors.add(color);
      if (colors.length >= 3) break;
    }
    return colors.toList();
  }

  @override
  Widget build(BuildContext context) {
    final gridDates = _buildGridDates();
    final rowCount = gridDates.length ~/ 7;

    return Column(
      children: [
        // ── 요일 헤더 행 ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          child: Row(
            children: _dayLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.dayLabel.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSizes.xs),

        // ── 날짜 그리드 ──
        ...List.generate(rowCount, (row) {
          final weekDates = gridDates.sublist(row * 7, row * 7 + 7);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            child: Row(
              children: weekDates.map((date) {
                final isCurrentMonth = date.month == displayedMonth.month;
                final isToday = _isToday(date);
                final isSelected = _isSelected(date) && !isToday;
                final dots = _eventDotsForDate(date);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateTap(date),
                    behavior: HitTestBehavior.opaque,
                    child: _DateCell(
                      day: date.day,
                      isCurrentMonth: isCurrentMonth,
                      isToday: isToday,
                      isSelected: isSelected,
                      eventDots: dots,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}

/// 개별 날짜 셀
class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.eventDots,
  });

  final int day;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<Color> eventDots;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 날짜 숫자 + 배경
          Container(
            width: 32,
            height: 32,
            decoration: isToday
                ? BoxDecoration(
                    color: AppColors.todayHighlight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  )
                : isSelected
                    ? BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      )
                    : null,
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: AppTypography.body.copyWith(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday
                    ? Colors.white
                    : isCurrentMonth
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ),
          ),

          // 이벤트 도트
          SizedBox(
            height: 8,
            child: eventDots.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: eventDots.map((color) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
