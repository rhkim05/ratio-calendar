import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/current_time_indicator.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_gesture_handler.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_grid.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_scroll_handler.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 타임라인 뷰 위젯
/// 세로 스크롤 가능한 24시간 타임라인 + 핀치 줌
///
/// - 좌측: 시간 라벨 컬럼 (00:00 ~ 23:00)
/// - 우측: 이벤트 블록이 겹쳐 배치되는 영역
/// - 핀치 줌: hourHeight를 30~150px 범위에서 동적 조절
/// - CurrentTimeIndicator 오버레이
/// - 빈 슬롯 탭: 1시간 단위 스냅, 더블탭으로 이벤트 생성
class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({
    super.key,
    required this.days,
    required this.eventsByDay,
    required this.calendarColors,
    this.onEmptySlotTap,
    this.onEventTap,
    this.isPinching = false,
  });

  /// 표시할 날짜 목록 (3-Day: 3개)
  final List<DateTime> days;

  /// 날짜별 이벤트 목록 (key: 날짜의 yyyy-MM-dd)
  final Map<String, List<EventEntity>> eventsByDay;

  /// 캘린더 ID별 색상 매핑
  final Map<String, Color> calendarColors;

  /// 빈 슬롯 탭 콜백 (시작/종료 시간으로 이벤트 생성, Future 반환 시 Sheet 닫힘 감지)
  final Future<void> Function(DateTime startTime, DateTime endTime)?
      onEmptySlotTap;

  /// 이벤트 탭 콜백 (Future 반환 시 Sheet 닫힘을 감지하여 하이라이트 해제)
  final Future<void> Function(EventEntity event)? onEventTap;

  /// 핀치 줌 진행 중 여부 (수직 스크롤 비활성화용)
  final bool isPinching;

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView>
    with TimelineScrollHandler, TimelineGestureHandler {
  @override
  void initState() {
    super.initState();
    initScrollHandler();
  }

  @override
  void didUpdateWidget(covariant TimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 뷰 전환 (day ↔ 3-day) 또는 날짜 변경 시 하이라이트 해제
    if (oldWidget.days.length != widget.days.length ||
        (oldWidget.days.isNotEmpty &&
            widget.days.isNotEmpty &&
            !oldWidget.days.first.isAtSameMomentAs(widget.days.first))) {
      clearSlotHighlight();
    }
  }

  @override
  void dispose() {
    disposeScrollHandler();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final hourHeight = ref.watch(hourHeightProvider);
    final totalHeight = 24 * hourHeight;

    return TapRegion(
      onTapOutside: (_) => clearSlotHighlight(),
      child: Listener(
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        onPointerCancel: onPointerCancel,
        child: SingleChildScrollView(
          controller: scrollController,
          physics:
              widget.isPinching ? const NeverScrollableScrollPhysics() : null,
          child: SizedBox(
            height: totalHeight,
            child: Stack(
              children: [
                // 시간 라벨 + 그리드 라인
                TimelineGrid(hourHeight: hourHeight),

                // 이벤트 영역
                Row(
                  children: [
                    const SizedBox(width: AppSizes.timeColumnWidth),
                    ...widget.days.map((date) {
                      final events =
                          widget.eventsByDay[_dateKey(date)] ?? [];
                      final now = DateTime.now();
                      final isToday = date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day;

                      // 이 컬럼에 해당하는 하이라이트 범위 계산
                      int? colHighlightStart;
                      int? colHighlightEnd;
                      if (highlightedDate != null &&
                          highlightedDate!.year == date.year &&
                          highlightedDate!.month == date.month &&
                          highlightedDate!.day == date.day) {
                        colHighlightStart = highlightStartMin;
                        colHighlightEnd = highlightEndMin;
                      }

                      return Expanded(
                        child: Container(
                          color: isToday ? AppColors.todayColumnTint : null,
                          child: DayEventsColumn(
                            events: events,
                            calendarColors: widget.calendarColors,
                            onEventTap: onEventTapWithScroll,
                            highlightedEventId: highlightedEventId,
                            date: date,
                            hourHeight: hourHeight,
                            highlightStartMin: colHighlightStart,
                            highlightEndMin: colHighlightEnd,
                            onTapAtMinute: (m) => handleTapAt(date, m),
                            onLongPressStartAtMinute: (m) =>
                                handleLongPressStart(date, m, hourHeight),
                            onLongPressMoveToMinute: (m) =>
                                handleLongPressMove(date, m),
                            onLongPressEnd: () => handleLongPressEnd(date),
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
                  hourHeight: hourHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
