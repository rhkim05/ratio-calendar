import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/calendar_header.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/month_grid.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/month_event_list.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/swipeable_timeline.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_view.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';
import 'package:ratio_calendar/features/event/presentation/providers/event_providers.dart';
import 'package:ratio_calendar/features/event/presentation/screens/event_create_sheet.dart';
import 'package:ratio_calendar/features/settings/presentation/providers/settings_providers.dart';
import 'package:ratio_calendar/features/event/presentation/screens/event_detail_sheet.dart';
import 'package:ratio_calendar/features/side_menu/presentation/screens/side_menu_screen.dart';

/// 캘린더 메인 화면 — Day / 3-Day / Month View 지원
class CalendarMainScreen extends ConsumerWidget {
  const CalendarMainScreen({super.key});

  static const _mockColors = AppColors.defaultCalendarColors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final visibleRange = ref.watch(visibleDateRangeProvider);
    final viewType = ref.watch(currentViewTypeProvider);
    final localEvents = ref.watch(localEventsByDateProvider);
    final accent = ref.watch(accentColorProvider);
    final calendarListAsync = ref.watch(calendarListProvider);

    // 캘린더 목록 에러 시 SnackBar 표시
    ref.listen(calendarListProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('캘린더 로드 실패: $error')),
          );
        },
      );
    });

    // 캘린더 목록 로딩 중이면 로딩 표시
    if (calendarListAsync.isLoading && !calendarListAsync.hasValue) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SideMenuScreen(),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더: 월/년도 + 아이콘들
            CalendarHeader(
              currentDate: selectedDate,
              onTodayTap: () => _goToToday(ref, viewType),
            ),

            // 뷰 타입에 따라 다른 본문
            Expanded(
              child: viewType == CalendarViewType.month
                  ? _buildMonthView(context, ref, selectedDate, localEvents, accent)
                  : _buildTimelineView(context, ref, visibleRange, viewType, localEvents, accent),
            ),
          ],
        ),
      ),

      // FAB(+) 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () => EventCreateSheet.show(
          context,
          initialDate: selectedDate,
        ),
        backgroundColor: AppColors.fabBackground,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // ── Month View ──

  Widget _buildMonthView(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    Map<String, List<EventEntity>> localEvents,
    Color accent,
  ) {
    final selectedKey = _dateKey(selectedDate);
    final selectedEvents = localEvents[selectedKey] ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          MonthGrid(
            displayedMonth: DateTime(selectedDate.year, selectedDate.month),
            selectedDate: selectedDate,
            eventsByDay: localEvents,
            calendarColors: _mockColors,
            startOfWeekDay: ref.watch(
              settingsProvider.select((s) => s.startOfWeek.weekday),
            ),
            accentColor: accent,
            onDateTap: (date) {
              ref.read(selectedDateProvider.notifier).select(date);
            },
          ),

          // 구분선
          Divider(color: AppColors.divider, height: 1),

          // 선택 날짜의 이벤트 리스트
          MonthEventList(
            selectedDate: selectedDate,
            events: selectedEvents,
            calendarColors: _mockColors,
            onEventTap: (event) => _showEventDetail(context, event),
          ),

          // 하단 여백
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Day / 3-Day View ──

  Widget _buildTimelineView(
    BuildContext context,
    WidgetRef ref,
    ({DateTime start, DateTime end}) visibleRange,
    CalendarViewType viewType,
    Map<String, List<EventEntity>> localEvents,
    Color accent,
  ) {
    final isDayView = viewType == CalendarViewType.day;

    return SwipeableTimeline(
      key: ValueKey(viewType),
      viewType: viewType,
      headerBuilder: (day) => isDayView
          ? _buildDayViewHeaderCell(day, accent)
          : _buildThreeDayHeaderCell(day, accent),
      bodyBuilder: ({
        required horizontalController,
        required dayColumnWidth,
        required totalDays,
        required indexToDate,
        required isPinching,
      }) {
        return TimelineView(
          horizontalController: horizontalController,
          dayColumnWidth: dayColumnWidth,
          totalDays: totalDays,
          indexToDate: indexToDate,
          eventsByDay: localEvents,
          calendarColors: _mockColors,
          isPinching: isPinching,
          onEmptySlotTap: (startTime, endTime) => EventCreateSheet.show(
            context,
            initialDate:
                DateTime(startTime.year, startTime.month, startTime.day),
            initialStartTime: startTime,
            initialEndTime: endTime,
          ),
          onEventTap: (event) => _showEventDetail(context, event),
        );
      },
    );
  }

  Future<void> _showEventDetail(BuildContext context, EventEntity event) {
    final color = _mockColors[event.calendarId] ?? AppColors.personal;
    return EventDetailSheet.show(
      context,
      event: event,
      calendarColor: color,
    );
  }

  // ── Helpers ──

  void _goToToday(WidgetRef ref, CalendarViewType viewType) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. 핀치 줌 기본값으로 리셋 (레이아웃 변경 유발)
    ref.read(hourHeightProvider.notifier).set(HourHeight.defaultHeight);

    // 2. 레이아웃 안정 후 날짜 이동 + 스크롤 애니메이션 동시 실행
    //    iOS에서 hourHeight 변경과 animateTo가 같은 프레임에 겹치면
    //    수평 스크롤 애니메이션이 취소되므로, 한 프레임 대기 후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedDateProvider.notifier).select(today);

      switch (viewType) {
        case CalendarViewType.day:
          ref.read(visibleDateRangeProvider.notifier).update(
                start: today, end: today,
              );
        case CalendarViewType.threeDay:
          ref.read(visibleDateRangeProvider.notifier).update(
                start: today, end: today.add(const Duration(days: 2)),
              );
        case CalendarViewType.month:
          break;
        default:
          break;
      }

      // 수직 스크롤 트리거 (수평 animateTo와 동시 실행됨)
      if (viewType != CalendarViewType.month) {
        ref.read(goToTodayTriggerProvider.notifier).fire();
      }
    });
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static const _dayNames3 = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _dayNamesFull = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
    'FRIDAY', 'SATURDAY', 'SUNDAY',
  ];

  /// 3-Day View 헤더 셀 (요일 약어 + 날짜 숫자)
  Widget _buildThreeDayHeaderCell(DateTime day, Color accent) {
    final isToday = _isToday(day);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _dayNames3[day.weekday - 1],
          style: AppTypography.dayLabel.copyWith(
            color: isToday ? accent : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        SizedBox(
          width: AppSizes.todayHighlightSize,
          height: AppSizes.todayHighlightSize,
          child: Container(
            decoration: isToday
                ? BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  )
                : null,
            alignment: Alignment.center,
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Text(
                day.day.toString(),
                style: AppTypography.dateNumber.copyWith(
                  color: isToday ? AppColors.background : AppColors.textPrimary,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Day View 헤더 셀 (요일 풀네임 + 날짜 숫자, today 하이라이트는 3-Day View와 동일)
  Widget _buildDayViewHeaderCell(DateTime day, Color accent) {
    final isToday = _isToday(day);
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.md,
        bottom: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _dayNamesFull[day.weekday - 1],
            style: AppTypography.dayLabel.copyWith(
              color:
                  isToday ? accent : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          SizedBox(
            width: AppSizes.todayHighlightSize,
            height: AppSizes.todayHighlightSize,
            child: Container(
              decoration: isToday
                  ? BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    )
                  : null,
              alignment: Alignment.center,
              child: OverflowBox(
                maxWidth: double.infinity,
                child: Text(
                  day.day.toString(),
                  style: AppTypography.dateNumber.copyWith(
                    color: isToday ? AppColors.background : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
