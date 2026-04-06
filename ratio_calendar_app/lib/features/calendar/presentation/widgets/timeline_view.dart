import 'dart:async';
import 'dart:math' show min, max;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// 빈 슬롯 탭 콜백 (시작/종료 시간으로 이벤트 생성, Future 반환 시 Sheet 닫힘 감지)
  final Future<void> Function(DateTime startTime, DateTime endTime)? onEmptySlotTap;

  /// 이벤트 탭 콜백 (Future 반환 시 Sheet 닫힘을 감지하여 하이라이트 해제)
  final Future<void> Function(EventEntity event)? onEventTap;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  late ScrollController _scrollController;

  /// 현재 상세 Sheet가 열려있는 이벤트 ID (강조 표시용)
  String? _highlightedEventId;

  /// 슬롯 하이라이트 상태 — 롱프레스로 활성화, 드래그로 범위 조절
  DateTime? _highlightedDate;
  int _highlightStartMin = 0; // 분 단위 (0–1440)
  int _highlightEndMin = 0;
  int _longPressAnchorMin = 0; // 드래그 기준점

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
    if (_highlightedDate != null) {
      setState(() => _highlightedDate = null);
    }
  }

  // ── 10분 스냅 헬퍼 ──
  static int _snapTo10Min(int minutes) =>
      ((minutes / 10).round() * 10).clamp(0, 24 * 60);

  // ── 롱프레스 제스처 핸들러 ──

  void _handleLongPressStart(DateTime date, int rawMinute) {
    final hour = (rawMinute / 60).floor().clamp(0, 23);
    setState(() {
      _highlightedDate = date;
      _highlightStartMin = hour * 60;
      _highlightEndMin = min((hour + 1) * 60, 24 * 60);
      _longPressAnchorMin = _snapTo10Min(rawMinute);
    });
    HapticFeedback.mediumImpact();
  }

  void _handleLongPressMove(DateTime date, int rawMinute) {
    if (_highlightedDate == null) return;
    final snapped = _snapTo10Min(rawMinute);
    setState(() {
      _highlightStartMin = min(_longPressAnchorMin, snapped);
      _highlightEndMin = max(_longPressAnchorMin, snapped);
      if (_highlightEndMin - _highlightStartMin < 10) {
        _highlightEndMin = _highlightStartMin + 10;
      }
    });
  }

  /// 빈 영역 탭: 하이라이트 범위 내면 이벤트 생성, 밖이면 1시간 하이라이트
  void _handleTapAt(DateTime date, int rawMinute) {
    if (_highlightedDate != null &&
        _highlightedDate!.year == date.year &&
        _highlightedDate!.month == date.month &&
        _highlightedDate!.day == date.day &&
        rawMinute >= _highlightStartMin &&
        rawMinute < _highlightEndMin) {
      _onHighlightedSlotTap(date);
    } else {
      // 첫 번째 탭 또는 다른 슬롯 → 1시간 하이라이트
      final hour = (rawMinute / 60).floor().clamp(0, 23);
      setState(() {
        _highlightedDate = date;
        _highlightStartMin = hour * 60;
        _highlightEndMin = min((hour + 1) * 60, 24 * 60);
      });
    }
  }

  /// 롱프레스 종료 → 바로 Sheet 열기
  void _handleLongPressEnd(DateTime date) {
    if (_highlightedDate == null) return;
    _onHighlightedSlotTap(date);
  }

  /// 하이라이트된 슬롯 탭 → 자동 스크롤 + Sheet 열기
  Future<void> _onHighlightedSlotTap(DateTime date) async {
    _suppressScrollDismiss = true;
    final blockTop = _highlightStartMin * AppSizes.hourHeight / 60;
    final blockHeight =
        (_highlightEndMin - _highlightStartMin) * AppSizes.hourHeight / 60;
    _animateScrollToBlock(blockTop, blockHeight);

    final startTime = DateTime(
      date.year, date.month, date.day,
      _highlightStartMin ~/ 60, _highlightStartMin % 60,
    );
    final endTime = DateTime(
      date.year, date.month, date.day,
      _highlightEndMin ~/ 60, _highlightEndMin % 60,
    );

    await widget.onEmptySlotTap?.call(startTime, endTime);

    _suppressScrollDismiss = false;
    if (mounted) {
      setState(() => _highlightedDate = null);
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
      _highlightedDate = null; // 이벤트 탭 시 슬롯 하이라이트도 해제
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

                  // 이 컬럼에 해당하는 하이라이트 범위 계산
                  int? colHighlightStart;
                  int? colHighlightEnd;
                  if (_highlightedDate != null &&
                      _highlightedDate!.year == date.year &&
                      _highlightedDate!.month == date.month &&
                      _highlightedDate!.day == date.day) {
                    colHighlightStart = _highlightStartMin;
                    colHighlightEnd = _highlightEndMin;
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
                        highlightStartMin: colHighlightStart,
                        highlightEndMin: colHighlightEnd,
                        onTapAtMinute: (m) => _handleTapAt(date, m),
                        onLongPressStartAtMinute: (m) => _handleLongPressStart(date, m),
                        onLongPressMoveToMinute: (m) => _handleLongPressMove(date, m),
                        onLongPressEnd: () => _handleLongPressEnd(date),
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
    this.highlightStartMin,
    this.highlightEndMin,
    this.highlightedEventId,
    this.onEventTap,
    this.onTapAtMinute,
    this.onLongPressStartAtMinute,
    this.onLongPressMoveToMinute,
    this.onLongPressEnd,
  });

  final List<EventEntity> events;
  final Map<String, Color> calendarColors;
  final DateTime date;
  final int? highlightStartMin;
  final int? highlightEndMin;
  final String? highlightedEventId;
  final void Function(EventEntity)? onEventTap;
  final void Function(int minute)? onTapAtMinute;
  final void Function(int minute)? onLongPressStartAtMinute;
  final void Function(int minute)? onLongPressMoveToMinute;
  final VoidCallback? onLongPressEnd;

  static int _yToMinute(double dy) =>
      (dy / AppSizes.hourHeight * 60).round().clamp(0, 24 * 60);

  @override
  Widget build(BuildContext context) {
    final hasHighlight =
        highlightStartMin != null && highlightEndMin != null;

    return GestureDetector(
      onTapUp: (details) {
        onTapAtMinute?.call(_yToMinute(details.localPosition.dy));
      },
      onLongPressStart: (details) {
        onLongPressStartAtMinute?.call(_yToMinute(details.localPosition.dy));
      },
      onLongPressMoveUpdate: (details) {
        onLongPressMoveToMinute?.call(_yToMinute(details.localPosition.dy));
      },
      onLongPressEnd: (_) => onLongPressEnd?.call(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // 하이라이트 블록 (가변 높이)
          if (hasHighlight)
            Positioned(
              top: highlightStartMin! * AppSizes.hourHeight / 60,
              left: 0,
              right: 0,
              height: (highlightEndMin! - highlightStartMin!) *
                  AppSizes.hourHeight /
                  60,
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
