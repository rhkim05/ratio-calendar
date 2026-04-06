import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';

/// 수평 연속 스크롤 + 날짜 스냅 방식 타임라인 래퍼
///
/// - ScrollController 기반 연속 스크롤 (PageView 대신)
/// - 각 날짜 컬럼 너비 = (화면 너비 - timeColumnWidth) / dayCount
/// - 손을 놓으면 가장 가까운 날짜 경계에 스냅 (스프링 애니메이션)
/// - 빠르게 스와이프하면 velocity에 비례해서 여러 일 이동 후 스냅
/// - 2손가락: 핀치 줌 (스크롤 비활성화)
/// - ±365일 범위 미리 생성 (무한 스크롤 느낌)
class SwipeableTimeline extends ConsumerStatefulWidget {
  const SwipeableTimeline({
    super.key,
    required this.viewType,
    required this.headerBuilder,
    required this.bodyBuilder,
  });

  final CalendarViewType viewType;

  /// 개별 날짜 헤더 셀 빌더
  final Widget Function(DateTime day) headerBuilder;

  /// 타임라인 본문 빌더
  final Widget Function({
    required ScrollController horizontalController,
    required double dayColumnWidth,
    required int totalDays,
    required DateTime Function(int index) indexToDate,
    required bool isPinching,
  }) bodyBuilder;

  @override
  ConsumerState<SwipeableTimeline> createState() => _SwipeableTimelineState();
}

class _SwipeableTimelineState extends ConsumerState<SwipeableTimeline> {
  static const int _bufferDays = 365;

  ScrollController? _hController;
  ScrollController? _headerController;
  late DateTime _baseDate;
  bool _initialized = false;

  /// 스와이프에 의한 날짜 변경인지 구분 (외부 변경과 무한루프 방지)
  bool _isSwipeNav = false;

  /// 활성 포인터 수 (2 이상이면 핀치 줌)
  int _pointerCount = 0;

  int get _dayCount => widget.viewType == CalendarViewType.day ? 1 : 3;
  int get _totalDays => _bufferDays * 2 + 1;

  double _dayColumnWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width - AppSizes.timeColumnWidth) /
        _dayCount;
  }

  DateTime _indexToDate(int index) {
    return DateTime(
      _baseDate.year,
      _baseDate.month,
      _baseDate.day + (index - _bufferDays),
    );
  }

  int _dateToIndex(DateTime date) {
    final base = DateTime(_baseDate.year, _baseDate.month, _baseDate.day);
    final target = DateTime(date.year, date.month, date.day);
    return _bufferDays + target.difference(base).inDays;
  }

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime.now();
  }

  @override
  void dispose() {
    _hController?.removeListener(_syncHeader);
    _hController?.dispose();
    _headerController?.dispose();
    super.dispose();
  }

  void _syncHeader() {
    if (_headerController != null &&
        _headerController!.hasClients &&
        _hController != null &&
        _hController!.hasClients) {
      _headerController!.jumpTo(_hController!.offset);
    }
  }

  void _handleScrollEnd() {
    if (_hController == null || !_hController!.hasClients) return;
    final columnWidth = _dayColumnWidth(context);
    final index = (_hController!.offset / columnWidth).round();
    final startDate = _indexToDate(index);
    final endDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day + _dayCount - 1,
    );

    _isSwipeNav = true;
    ref
        .read(visibleDateRangeProvider.notifier)
        .update(start: startDate, end: endDate);
    ref.read(selectedDateProvider.notifier).select(startDate);
  }

  @override
  Widget build(BuildContext context) {
    final visibleRange = ref.watch(visibleDateRangeProvider);
    final columnWidth = _dayColumnWidth(context);

    if (!_initialized) {
      _baseDate = visibleRange.start;
      final initialOffset = _dateToIndex(visibleRange.start) * columnWidth;
      _hController?.removeListener(_syncHeader);
      _hController?.dispose();
      _headerController?.dispose();
      _hController = ScrollController(initialScrollOffset: initialOffset);
      _headerController = ScrollController(initialScrollOffset: initialOffset);
      _hController!.addListener(_syncHeader);
      _initialized = true;
    } else if (_isSwipeNav) {
      _isSwipeNav = false;
    } else {
      // 외부 날짜 변경 (Today 버튼, 월 뷰 선택 등)
      final targetOffset = _dateToIndex(visibleRange.start) * columnWidth;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hController != null && _hController!.hasClients) {
          _hController!.jumpTo(targetOffset);
        }
      });
    }

    final isPinching = _pointerCount >= 2;

    return Listener(
      onPointerDown: (_) => setState(() => _pointerCount++),
      onPointerUp: (_) =>
          setState(() => _pointerCount = max(0, _pointerCount - 1)),
      onPointerCancel: (_) =>
          setState(() => _pointerCount = max(0, _pointerCount - 1)),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.axis == Axis.horizontal) {
            _handleScrollEnd();
          }
          return false;
        },
        child: Column(
          children: [
            // 헤더
            _buildHeader(columnWidth),
            // 바디
            Expanded(
              child: widget.bodyBuilder(
                horizontalController: _hController!,
                dayColumnWidth: columnWidth,
                totalDays: _totalDays,
                indexToDate: _indexToDate,
                isPinching: isPinching,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double columnWidth) {
    final isDayView = widget.viewType == CalendarViewType.day;
    final headerHeight =
        isDayView ? AppSizes.dayHeaderHeight + 20 : AppSizes.dayHeaderHeight;

    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSizes.timeColumnWidth),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _headerController,
              physics: const NeverScrollableScrollPhysics(),
              itemExtent: columnWidth,
              itemCount: _totalDays,
              itemBuilder: (context, index) {
                return widget.headerBuilder(_indexToDate(index));
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 날짜 경계 스냅 스크롤 물리
///
/// - 느린 스와이프: 1일 이동
/// - 빠른 스와이프: velocity에 비례하여 여러 일 이동 (최대 7일)
/// - 스프링 애니메이션으로 가장 가까운 날짜 경계에 스냅
class DaySnapScrollPhysics extends ScrollPhysics {
  const DaySnapScrollPhysics({required this.dayColumnWidth, super.parent});

  final double dayColumnWidth;

  @override
  DaySnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DaySnapScrollPhysics(
      dayColumnWidth: dayColumnWidth,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final currentDay = position.pixels / dayColumnWidth;
    final velocityPerDay = velocity / dayColumnWidth;

    double targetDay;
    if (velocityPerDay.abs() > 2.0) {
      // 빠른 스와이프: 속도에 비례하여 여러 일 이동 (최대 7일)
      final extraDays = (velocityPerDay * 0.15).round().clamp(-7, 7);
      targetDay = (currentDay.round() + extraDays).toDouble();
    } else if (velocity > tolerance.velocity) {
      // 오른쪽→왼쪽 (다음 날)
      targetDay = currentDay.ceil().toDouble();
    } else if (velocity < -tolerance.velocity) {
      // 왼쪽→오른쪽 (이전 날)
      targetDay = currentDay.floor().toDouble();
    } else {
      // 드래그 거리 기반 스냅
      targetDay = currentDay.round().toDouble();
    }

    final targetPixels = targetDay * dayColumnWidth;
    return targetPixels.clamp(
        position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // 경계 도달 시 기본 동작
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final target =
        _getTargetPixels(position, toleranceFor(position), velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: toleranceFor(position),
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
