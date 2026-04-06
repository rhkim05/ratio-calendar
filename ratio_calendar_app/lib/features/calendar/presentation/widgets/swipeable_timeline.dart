import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';

/// 수평 스와이프로 날짜를 이동하는 타임라인 래퍼
///
/// - 1손가락 수평 스와이프: 날짜 이동 (PageView 스타일)
/// - 살짝 스와이프: 1일 이동
/// - 크게 스와이프: velocity에 비례하여 여러 일 이동
/// - 2손가락: 핀치 줌 (PageView 비활성화)
class SwipeableTimeline extends ConsumerStatefulWidget {
  const SwipeableTimeline({
    super.key,
    required this.viewType,
    required this.pageBuilder,
  });

  final CalendarViewType viewType;

  /// 날짜 목록과 핀치 상태를 받아 타임라인 페이지를 빌드하는 콜백
  final Widget Function(List<DateTime> days, bool isPinching) pageBuilder;

  @override
  ConsumerState<SwipeableTimeline> createState() => _SwipeableTimelineState();
}

class _SwipeableTimelineState extends ConsumerState<SwipeableTimeline> {
  static const int _totalPages = 100000;
  static const int _initialPage = 50000;

  late PageController _pageController;
  late DateTime _baseDate;
  bool _baseDateInitialized = false;

  /// 스와이프에 의한 날짜 변경인지 구분 (외부 변경과 무한루프 방지)
  bool _isSwipeNav = false;

  /// 활성 포인터 수 (2 이상이면 핀치 줌)
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _baseDate = DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _dayCount => widget.viewType == CalendarViewType.day ? 1 : 3;

  DateTime _pageToDate(int page) {
    return DateTime(
      _baseDate.year,
      _baseDate.month,
      _baseDate.day + (page - _initialPage),
    );
  }

  int _dateToPage(DateTime date) {
    final base = DateTime(_baseDate.year, _baseDate.month, _baseDate.day);
    final target = DateTime(date.year, date.month, date.day);
    return _initialPage + target.difference(base).inDays;
  }

  void _onPageChanged(int page) {
    _isSwipeNav = true;
    final newStart = _pageToDate(page);
    final newEnd = newStart.add(Duration(days: _dayCount - 1));
    ref
        .read(visibleDateRangeProvider.notifier)
        .update(start: newStart, end: newEnd);
    ref.read(selectedDateProvider.notifier).select(newStart);
  }

  @override
  Widget build(BuildContext context) {
    final visibleRange = ref.watch(visibleDateRangeProvider);

    // 첫 빌드: baseDate 설정
    if (!_baseDateInitialized) {
      _baseDate = visibleRange.start;
      _baseDateInitialized = true;
    } else if (_isSwipeNav) {
      // 스와이프에 의한 변경 → 무시 (이미 처리됨)
      _isSwipeNav = false;
    } else {
      // 외부 날짜 변경 (Today 버튼, 월 뷰 선택 등) → PageView 점프
      final expectedPage = _dateToPage(visibleRange.start);
      if (_pageController.hasClients) {
        final currentPage = _pageController.page?.round() ?? _initialPage;
        if (currentPage != expectedPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(expectedPage);
            }
          });
        }
      }
    }

    final isPinching = _pointerCount >= 2;

    return Listener(
      onPointerDown: (_) => setState(() => _pointerCount++),
      onPointerUp: (_) =>
          setState(() => _pointerCount = max(0, _pointerCount - 1)),
      onPointerCancel: (_) =>
          setState(() => _pointerCount = max(0, _pointerCount - 1)),
      child: PageView.builder(
        controller: _pageController,
        physics: isPinching
            ? const NeverScrollableScrollPhysics()
            : const _VelocityPageScrollPhysics(),
        onPageChanged: _onPageChanged,
        itemCount: _totalPages,
        itemBuilder: (context, index) {
          final startDate = _pageToDate(index);
          final days = List.generate(
            _dayCount,
            (i) => DateTime(
                startDate.year, startDate.month, startDate.day + i),
          );
          return widget.pageBuilder(days, isPinching);
        },
      ),
    );
  }
}

/// 속도 기반 다중 페이지 점프를 지원하는 커스텀 ScrollPhysics
///
/// - 살짝 스와이프: 1페이지 (1일) 이동
/// - 빠른 스와이프: velocity에 비례하여 여러 페이지 이동 (최대 7일)
class _VelocityPageScrollPhysics extends ScrollPhysics {
  const _VelocityPageScrollPhysics({super.parent});

  @override
  _VelocityPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _VelocityPageScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / position.viewportDimension;
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final page = _getPage(position);
    final velocityPerPage = velocity / position.viewportDimension;

    double targetPage;
    if (velocityPerPage.abs() > 2.0) {
      // 빠른 스와이프: 속도에 비례하여 여러 일 이동 (최대 7일)
      final extraPages = (velocityPerPage * 0.15).round().clamp(-7, 7);
      targetPage = (page.round() + extraPages).toDouble();
    } else if (velocity > tolerance.velocity) {
      // 오른쪽→왼쪽 (다음 날)
      targetPage = page.ceil().toDouble();
    } else if (velocity < -tolerance.velocity) {
      // 왼쪽→오른쪽 (이전 날)
      targetPage = page.floor().toDouble();
    } else {
      // 드래그 거리 기반 스냅
      targetPage = page.round().toDouble();
    }

    return targetPage * position.viewportDimension;
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
