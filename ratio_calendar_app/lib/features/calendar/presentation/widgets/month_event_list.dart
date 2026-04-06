import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 선택된 날짜의 이벤트 리스트 (월 뷰 하단)
///
/// Stitch calendar_month 디자인:
///   - "SEPTEMBER 20" 날짜 라벨
///   - 카드 형태: 연한 배경 + 좌측 4px 컬러 보더
///   - 제목 + 시간 표시
class MonthEventList extends StatelessWidget {
  const MonthEventList({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.calendarColors,
    this.onEventTap,
  });

  final DateTime selectedDate;
  final List<EventEntity> events;
  final Map<String, Color> calendarColors;
  final void Function(EventEntity event)? onEventTap;

  static const _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL',
    'MAY', 'JUNE', 'JULY', 'AUGUST',
    'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_months[selectedDate.month - 1]} ${selectedDate.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 날짜 라벨 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm,
          ),
          child: Text(
            dateLabel,
            style: AppTypography.dayLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // ── 이벤트 카드 리스트 ──
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.lg,
            ),
            child: Text(
              'No events',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ...events.map((event) {
            final color =
                calendarColors[event.calendarId] ?? AppColors.personal;
            return _MonthEventCard(
              event: event,
              color: color,
              formatTime: _formatTime,
              onTap: () => onEventTap?.call(event),
            );
          }),
      ],
    );
  }
}

/// 이벤트 배경색 매핑 (event_block.dart와 동일)
final _backgroundColors = <Color, Color>{
  AppColors.blueBorder: AppColors.blueBackground,
  AppColors.tealBorder: AppColors.tealBackground,
  AppColors.amberBorder: AppColors.amberBackground,
  AppColors.orangeBorder: AppColors.orangeBackground,
};

/// 월 뷰용 이벤트 카드
class _MonthEventCard extends StatelessWidget {
  const _MonthEventCard({
    required this.event,
    required this.color,
    required this.formatTime,
    this.onTap,
  });

  final EventEntity event;
  final Color color;
  final String Function(DateTime) formatTime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = _backgroundColors[color] ?? color.withValues(alpha: 0.06);
    final timeText =
        '${formatTime(event.startTime)} - ${formatTime(event.endTime)}';

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.eventBorderRadius),
          child: Container(
            color: bgColor,
            child: Row(
              children: [
                // 좌측 4px 컬러 보더
                Container(
                  width: AppSizes.eventLeftBorderWidth,
                  height: 56,
                  color: color,
                ),

                // 내용
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm + AppSizes.xs,
                      vertical: AppSizes.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: AppTypography.eventTitle.copyWith(
                            color: color,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeText,
                          style: AppTypography.eventTime.copyWith(
                            color: color.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
