import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

import 'package:ratio_calendar/features/calendar/presentation/widgets/current_time_indicator.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/event_block.dart';

/// 타임라인 뷰 위젯
/// 세로 스크롤 가능한 24시간 타임라인
///
/// - 좌측: 시간 라벨 컬럼 (00:00 ~ 23:00)
/// - 우측: 이벤트 블록이 겹쳐 배치되는 영역
/// - 1시간 = 60px 높이
/// - CurrentTimeIndicator 오버레이
/// - 빈 슬롯 탭: 1시간 단위 스냅, 더블탭으로 이벤트 생성
class TimelineView extends StatefulWidget {
  const TimelineView({
    super.key,
    required this.days,
    required this.eventsByDay,
    required this.calendarColors,
    this.onEmptySlotTap,
    this.onEventTap,
  });

  /// 표시할 날짜 목록 (3-Day: 3개)
  final List<DateTime> days;

  /// 날짜별 이벤트 목록 (key: 날짜의 yyyy-MM-dd)
  final Map<String, List<EventEntity>> eventsByDay;

  /// 캘린더 ID별 색상 매핑
  final Map<String, Color> calendarColors;

  /// 빈 슬롯 탭 콜백 (해당 시간으로 이벤트 생성)
  final void Function(DateTime dateTime)? onEmptySlotTap;

  /// 이벤트 탭 콜백
  final void Function(EventEntity event)? onEventTap;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  late ScrollController _scrollController;

  /// 현재 하이라이트된 슬롯 (1시간 블록의 시작 시각, null이면 없음)
  DateTime? _highlightedSlot;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    // 현재 시각 2시간 전으로 스크롤 (여유 있게 보이도록)
    final targetOffset = ((now.hour - 2).clamp(0, 23)) * AppSizes.hourHeight;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(targetOffset);
    }
  }

  int _findTodayColumnIndex() {
    final now = DateTime.now();
    for (var i = 0; i < widget.days.length; i++) {
      final d = widget.days[i];
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        return i;
      }
    }
    return -1;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// 슬롯 탭 처리: 1시간 단위 스냅
  void _onSlotTap(DateTime date, int hour) {
    final slotStart = DateTime(date.year, date.month, date.day, hour);

    if (_highlightedSlot != null &&
        _highlightedSlot!.isAtSameMomentAs(slotStart)) {
      // 같은 슬롯 두 번째 탭 → 이벤트 생성
      widget.onEmptySlotTap?.call(slotStart);
      setState(() => _highlightedSlot = null);
    } else {
      // 첫 번째 탭 또는 다른 슬롯 → 하이라이트
      setState(() => _highlightedSlot = slotStart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = 24 * AppSizes.hourHeight;

    return SingleChildScrollView(
      controller: _scrollController,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: [
            // 시간 라벨 + 그리드 라인
            _TimeGrid(),

            // 이벤트 영역
            Row(
              children: [
                const SizedBox(width: AppSizes.timeColumnWidth),
                ...widget.days.map((date) {
                  final events = widget.eventsByDay[_dateKey(date)] ?? [];
                  final now = DateTime.now();
                  final isToday = date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  // 이 컬럼에 해당하는 하이라이트 시간 계산
                  int? highlightedHour;
                  if (_highlightedSlot != null &&
                      _highlightedSlot!.year == date.year &&
                      _highlightedSlot!.month == date.month &&
                      _highlightedSlot!.day == date.day) {
                    highlightedHour = _highlightedSlot!.hour;
                  }

                  return Expanded(
                    child: Container(
                      color: isToday ? AppColors.todayColumnTint : null,
                      child: _DayEventsColumn(
                        events: events,
                        calendarColors: widget.calendarColors,
                        onEventTap: widget.onEventTap,
                        date: date,
                        highlightedHour: highlightedHour,
                        onSlotTap: (hour) => _onSlotTap(date, hour),
                      ),
                    ),
                  );
                }),
              ],
            ),

            // 현재 시각 인디케이터
            CurrentTimeIndicator(
              columnCount: widget.days.length,
              todayColumnIndex: _findTodayColumnIndex(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 24시간 시간 라벨 + 수평 그리드
class _TimeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(24, (hour) {
        final label = '${hour.toString().padLeft(2, '0')}:00';
        return SizedBox(
          height: AppSizes.hourHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시간 라벨 — 매우 연한 회색, 11px
              SizedBox(
                width: AppSizes.timeColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.timeLabel,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),

              // 수평 그리드 라인
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.divider,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// 하루 분량의 이벤트를 세로로 배치하는 컬럼
class _DayEventsColumn extends StatelessWidget {
  const _DayEventsColumn({
    required this.events,
    required this.calendarColors,
    required this.date,
    required this.onSlotTap,
    this.highlightedHour,
    this.onEventTap,
  });

  final List<EventEntity> events;
  final Map<String, Color> calendarColors;
  final DateTime date;
  final int? highlightedHour;
  final void Function(int hour) onSlotTap;
  final void Function(EventEntity)? onEventTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        // 1시간 단위 스냅
        final hour =
            (details.localPosition.dy / AppSizes.hourHeight).floor().clamp(0, 23);
        onSlotTap(hour);
      },
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // 하이라이트 블록
          if (highlightedHour != null)
            Positioned(
              top: highlightedHour! * AppSizes.hourHeight,
              left: 0,
              right: 0,
              height: AppSizes.hourHeight,
              child: const _SlotHighlight(),
            ),

          // 이벤트 블록들
          ...events.map((event) {
            final startMinutes =
                event.startTime.hour * 60 + event.startTime.minute;
            final topOffset = startMinutes * AppSizes.hourHeight / 60;
            final color =
                calendarColors[event.calendarId] ?? AppColors.personal;

            return Positioned(
              top: topOffset,
              left: 0,
              right: 0,
              child: EventBlock(
                event: event,
                color: color,
                onTap: () => onEventTap?.call(event),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 빈 슬롯 하이라이트 — 점선 테두리 + 연한 배경
class _SlotHighlight extends StatelessWidget {
  const _SlotHighlight();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.outlineVariant,
          strokeWidth: 1.0,
          dashWidth: 4,
          dashGap: 3,
          borderRadius: AppSizes.eventBorderRadius,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.outlineVariant.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppSizes.eventBorderRadius),
          ),
        ),
      ),
    );
  }
}

/// 점선 테두리 CustomPainter
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, (distance + len).clamp(0, metric.length)),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      borderRadius != oldDelegate.borderRadius;
}
