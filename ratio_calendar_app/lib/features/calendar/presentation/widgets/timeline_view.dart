import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/swipeable_timeline.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_gesture_handler.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_grid.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_scroll_handler.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 타임라인 뷰 위젯
/// 세로 스크롤 + 수평 연속 스크롤 가능한 24시간 타임라인
///
/// - 좌측: 시간 라벨 컬럼 (고정, 수평 스크롤 영향 없음)
/// - 우측: 날짜별 이벤트 컬럼 (수평 연속 스크롤 + 날짜 스냅)
/// - 핀치 줌: hourHeight를 30~150px 범위에서 동적 조절
/// - CurrentTimeMarker: 오늘 컬럼에만 빨간 점 + 수평선
/// - 빈 슬롯 탭 / 롱프레스 → 이벤트 생성
class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({
    super.key,
    required this.horizontalController,
    required this.dayColumnWidth,
    required this.totalDays,
    required this.indexToDate,
    required this.eventsByDay,
    required this.calendarColors,
    this.onEmptySlotTap,
    this.onEventTap,
    this.isPinching = false,
  });

  /// 수평 스크롤 컨트롤러 (SwipeableTimeline에서 제공)
  final ScrollController horizontalController;

  /// 개별 날짜 컬럼 너비
  final double dayColumnWidth;

  /// 전체 날짜 수
  final int totalDays;

  /// 인덱스 → 날짜 변환 함수
  final DateTime Function(int index) indexToDate;

  /// 날짜별 이벤트 목록 (key: yyyy-MM-dd)
  final Map<String, List<EventEntity>> eventsByDay;

  /// 캘린더 ID별 색상 매핑
  final Map<String, Color> calendarColors;

  /// 빈 슬롯 탭 콜백 (시작/종료 시간으로 이벤트 생성)
  final Future<void> Function(DateTime startTime, DateTime endTime)?
      onEmptySlotTap;

  /// 이벤트 탭 콜백
  final Future<void> Function(EventEntity event)? onEventTap;

  /// 핀치 줌 진행 중 여부 (수직/수평 스크롤 비활성화용)
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
    // 뷰 전환 (day ↔ 3-day) 시 하이라이트 해제
    if (oldWidget.dayColumnWidth != widget.dayColumnWidth) {
      clearSlotHighlight();
    }
  }

  @override
  void dispose() {
    disposeScrollHandler();
    super.dispose();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final hourHeight = ref.watch(hourHeightProvider);
    final totalHeight = 24 * hourHeight;

    // Today 버튼 트리거 감지 → 현재 시각 중앙 정렬 스크롤
    ref.listen(goToTodayTriggerProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        animateToCurrentTimeCentered();
      });
    });

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
                // 시간 라벨 + 그리드 라인 (고정, 전체 너비)
                TimelineGrid(hourHeight: hourHeight),

                // 날짜 컬럼들 (수평 연속 스크롤)
                Positioned(
                  left: AppSizes.timeColumnWidth,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: widget.horizontalController,
                    physics: widget.isPinching
                        ? const NeverScrollableScrollPhysics()
                        : DaySnapScrollPhysics(
                            dayColumnWidth: widget.dayColumnWidth),
                    itemExtent: widget.dayColumnWidth,
                    itemCount: widget.totalDays,
                    itemBuilder: (context, index) {
                      return _buildDayColumn(index, hourHeight);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayColumn(int index, double hourHeight) {
    final date = widget.indexToDate(index);
    final events = widget.eventsByDay[_dateKey(date)] ?? [];
    final isToday = _isToday(date);

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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
            onLongPressMoveToMinute: (m) => handleLongPressMove(date, m),
            onLongPressEnd: () => handleLongPressEnd(date),
          ),
        ),
        // 현재 시각 인디케이터 (오늘 컬럼만)
        if (isToday) _CurrentTimeMarker(hourHeight: hourHeight),
      ],
    );
  }
}

/// 현재 시각 마커 — 컬럼 내 빨간 점 + 수평선
///
/// 1분마다 위치 갱신
class _CurrentTimeMarker extends StatefulWidget {
  const _CurrentTimeMarker({required this.hourHeight});
  final double hourHeight;

  @override
  State<_CurrentTimeMarker> createState() => _CurrentTimeMarkerState();
}

class _CurrentTimeMarkerState extends State<_CurrentTimeMarker> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = (_now.hour * 60 + _now.minute) * widget.hourHeight / 60;
    final dotSize = AppSizes.currentTimeIndicatorDot;

    return Positioned(
      top: top - dotSize / 2,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // 빨간 점
          Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              color: AppColors.currentTimeIndicator,
              shape: BoxShape.circle,
            ),
          ),
          // 수평선
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.currentTimeIndicator,
            ),
          ),
        ],
      ),
    );
  }
}
