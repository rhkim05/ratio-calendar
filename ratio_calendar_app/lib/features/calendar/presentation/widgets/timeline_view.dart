import 'dart:async';
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

  /// 빈 슬롯 탭 콜백 (해당 시간으로 이벤트 생성, Future 반환 시 Sheet 닫힘 감지)
  final Future<void> Function(DateTime dateTime)? onEmptySlotTap;

  /// 이벤트 탭 콜백 (Future 반환 시 Sheet 닫힘을 감지하여 하이라이트 해제)
  final Future<void> Function(EventEntity event)? onEventTap;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  late ScrollController _scrollController;

  /// 현재 하이라이트된 슬롯 (1시간 블록의 시작 시각, null이면 없음)
  DateTime? _highlightedSlot;

  /// 현재 상세 Sheet가 열려있는 이벤트 ID (강조 표시용)
  String? _highlightedEventId;

  /// auto-scroll 애니메이션 중 스크롤 리스너가 하이라이트를 해제하지 않도록 억제
  bool _suppressScrollDismiss = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onUserScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
  }

  @override
  void didUpdateWidget(covariant TimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 뷰 전환 (day ↔ 3-day) 또는 날짜 변경 시 하이라이트 해제
    if (oldWidget.days.length != widget.days.length ||
        (oldWidget.days.isNotEmpty &&
            widget.days.isNotEmpty &&
            !oldWidget.days.first.isAtSameMomentAs(widget.days.first))) {
      _clearSlotHighlight();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onUserScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 스크롤 시 슬롯 하이라이트 해제 (auto-scroll 중에는 억제)
  void _onUserScroll() {
    if (_suppressScrollDismiss) return;
    _clearSlotHighlight();
  }

  void _clearSlotHighlight() {
    if (_highlightedSlot != null) {
      setState(() => _highlightedSlot = null);
    }
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    // 현재 시각 2시간 전으로 스크롤 (여유 있게 보이도록)
    final targetOffset = ((now.hour - 2).clamp(0, 23)) * AppSizes.hourHeight;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(targetOffset);
    }
  }

  /// 타임라인 블록 중심이 Sheet 위 가시 영역 중앙에 오도록 스크롤 offset 계산
  ///
  /// [blockTopPx]   — 블록의 타임라인 내 Y 좌표 (px)
  /// [blockHeightPx] — 블록 높이 (px)
  ///
  /// 계산:
  ///   visibleTop  = 타임라인 위젯의 화면 Y 좌표 (SafeArea + 헤더 자동 반영)
  ///   visibleBottom = screenHeight - sheetHeight
  ///   visibleCenter = (visibleTop + visibleBottom) / 2
  ///   scrollTo = blockCenter - (visibleCenter - visibleTop) - downwardBias
  void _animateScrollToBlock(double blockTopPx, double blockHeightPx) {
    if (!_scrollController.hasClients) return;

    final screenHeight = MediaQuery.of(context).size.height;

    // 1) visibleTop: 타임라인 위젯의 화면 상 Y 위치
    final renderBox = context.findRenderObject() as RenderBox;
    final visibleTop = renderBox.localToGlobal(Offset.zero).dy;

    // 2) visibleBottom: 전체 화면 높이 - Bottom Sheet 예상 높이
    final sheetHeight = screenHeight * AppSizes.sheetEstimatedHeightFraction;
    final visibleBottom = screenHeight - sheetHeight;

    // 3) visibleCenter: 두 경계의 정중앙 (화면 좌표)
    final visibleCenter = (visibleTop + visibleBottom) / 2;

    // 4) blockCenter → targetOffset
    final blockCenter = blockTopPx + blockHeightPx / 2;
    const downwardBias = 50.0;
    final targetOffset =
        (blockCenter - (visibleCenter - visibleTop) - downwardBias).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    unawaited(_scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ));
  }

  /// 이벤트 탭 시: 강조 + 스크롤 애니메이션 + onEventTap 콜백
  /// Sheet가 닫히면 (Future 완료) 강조 해제
  Future<void> _onEventTapWithScroll(EventEntity event) async {
    setState(() {
      _highlightedEventId = event.id;
      _highlightedSlot = null; // 이벤트 탭 시 슬롯 하이라이트도 해제
    });

    // 이벤트 블록의 타임라인 내 위치 & 높이
    final startMinutes = event.startTime.hour * 60 + event.startTime.minute;
    final blockTop = startMinutes * AppSizes.hourHeight / 60;
    final durationMinutes =
        event.endTime.difference(event.startTime).inMinutes;
    final blockHeight = durationMinutes * AppSizes.hourHeight / 60;

    _animateScrollToBlock(blockTop, blockHeight);

    // Sheet 열기 — Future 완료 = Sheet 닫힘
    await widget.onEventTap?.call(event);

    // 강조 표시 OFF
    if (mounted) {
      setState(() => _highlightedEventId = null);
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
  /// 두 번째 탭 시 하이라이트 블록 중심으로 자동 스크롤 + Sheet 열기
  Future<void> _onSlotTap(DateTime date, int hour) async {
    final slotStart = DateTime(date.year, date.month, date.day, hour);

    if (_highlightedSlot != null &&
        _highlightedSlot!.isAtSameMomentAs(slotStart)) {
      // 같은 슬롯 두 번째 탭 → 스크롤 + 이벤트 생성
      _suppressScrollDismiss = true;
      final blockTop = hour * AppSizes.hourHeight;
      _animateScrollToBlock(blockTop, AppSizes.hourHeight);

      await widget.onEmptySlotTap?.call(slotStart);

      // Sheet 닫힘 후 하이라이트 해제
      _suppressScrollDismiss = false;
      if (mounted) {
        setState(() => _highlightedSlot = null);
      }
    } else {
      // 첫 번째 탭 또는 다른 슬롯 → 하이라이트
      setState(() => _highlightedSlot = slotStart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = 24 * AppSizes.hourHeight;

    return TapRegion(
      onTapOutside: (_) => _clearSlotHighlight(),
      child: SingleChildScrollView(
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
                        onEventTap: _onEventTapWithScroll,
                        highlightedEventId: _highlightedEventId,
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
    this.highlightedEventId,
    this.onEventTap,
  });

  final List<EventEntity> events;
  final Map<String, Color> calendarColors;
  final DateTime date;
  final int? highlightedHour;
  final String? highlightedEventId;
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
                isHighlighted: event.id == highlightedEventId,
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
