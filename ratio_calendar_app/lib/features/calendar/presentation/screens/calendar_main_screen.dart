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
import 'package:ratio_calendar/features/event/presentation/screens/event_detail_sheet.dart';
import 'package:ratio_calendar/features/side_menu/presentation/screens/side_menu_screen.dart';

/// 캘린더 메인 화면 — Day / 3-Day / Month View 지원
class CalendarMainScreen extends ConsumerWidget {
  const CalendarMainScreen({super.key});

  static const _mockColors = <String, Color>{
    'sprint': AppColors.blueBorder,
    'design': AppColors.tealBorder,
    'deepwork': AppColors.amberBorder,
    'standup': AppColors.orangeBorder,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final visibleRange = ref.watch(visibleDateRangeProvider);
    final viewType = ref.watch(currentViewTypeProvider);
    final localEvents = ref.watch(localEventsByDateProvider);

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
                  ? _buildMonthView(context, ref, selectedDate, localEvents)
                  : _buildTimelineView(context, ref, visibleRange, viewType, localEvents),
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
  ) {
    final mockEvents = _buildMonthMockEvents(selectedDate);
    // 로컬 이벤트를 mock 이벤트에 머지
    _mergeEvents(mockEvents, localEvents);

    final selectedKey = _dateKey(selectedDate);
    final selectedEvents = mockEvents[selectedKey] ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          MonthGrid(
            displayedMonth: DateTime(selectedDate.year, selectedDate.month),
            selectedDate: selectedDate,
            eventsByDay: mockEvents,
            calendarColors: _mockColors,
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
  ) {
    final isDayView = viewType == CalendarViewType.day;

    // Mock 이벤트는 오늘/내일만 해당 — 날짜 범위 무관하게 생성
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final mockEvents = _buildMockEvents([today, tomorrow]);
    _mergeEvents(mockEvents, localEvents);

    return SwipeableTimeline(
      key: ValueKey(viewType),
      viewType: viewType,
      headerBuilder: (day) => isDayView
          ? _buildDayViewHeaderCell(day)
          : _buildThreeDayHeaderCell(day),
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
          eventsByDay: mockEvents,
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

  /// 로컬 이벤트를 기존 이벤트 맵에 머지
  void _mergeEvents(
    Map<String, List<EventEntity>> target,
    Map<String, List<EventEntity>> source,
  ) {
    for (final entry in source.entries) {
      target.putIfAbsent(entry.key, () => []).addAll(entry.value);
    }
  }

  void _goToToday(WidgetRef ref, CalendarViewType viewType) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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
        // month view는 selectedDate만 갱신하면 됨
        break;
      default:
        break;
    }
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
  Widget _buildThreeDayHeaderCell(DateTime day) {
    final isToday = _isToday(day);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _dayNames3[day.weekday - 1],
          style: AppTypography.dayLabel.copyWith(
            color: isToday ? AppColors.todayHighlight : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          width: AppSizes.todayHighlightSize,
          height: AppSizes.todayHighlightSize,
          decoration: isToday
              ? BoxDecoration(
                  color: AppColors.todayHighlight,
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            day.day.toString(),
            style: AppTypography.dateNumber.copyWith(
              color: isToday ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Day View 헤더 셀 (요일 풀네임 + 날짜 숫자)
  Widget _buildDayViewHeaderCell(DateTime day) {
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
                  isToday ? AppColors.todayHighlight : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            day.day.toString(),
            style: AppTypography.dateNumber.copyWith(
              color: isToday ? AppColors.todayHighlight : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Month View용 Mock 이벤트 — 해당 월 전체에 샘플 데이터 배치
  Map<String, List<EventEntity>> _buildMonthMockEvents(DateTime selected) {
    final result = <String, List<EventEntity>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 오늘 이벤트
    final todayKey = _dateKey(today);
    result[todayKey] = [
      EventEntity(
        id: 'month-1',
        title: 'Design Sync',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 10, 0),
        endTime: DateTime(today.year, today.month, today.day, 11, 0),
        calendarId: 'design',
        createdAt: now,
        updatedAt: now,
      ),
      EventEntity(
        id: 'month-2',
        title: 'Project Drafting',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 14, 0),
        endTime: DateTime(today.year, today.month, today.day, 16, 30),
        calendarId: 'deepwork',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // 내일
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowKey = _dateKey(tomorrow);
    result[tomorrowKey] = [
      EventEntity(
        id: 'month-3',
        title: 'Team Standup',
        date: tomorrow,
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 30),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
        calendarId: 'standup',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // 2일 전
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final twoDaysAgoKey = _dateKey(twoDaysAgo);
    result[twoDaysAgoKey] = [
      EventEntity(
        id: 'month-4',
        title: 'Sprint Planning',
        date: twoDaysAgo,
        startTime: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 9, 0),
        endTime: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 10, 0),
        calendarId: 'sprint',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // 5일 후
    final fiveDaysLater = today.add(const Duration(days: 5));
    final fiveDaysKey = _dateKey(fiveDaysLater);
    result[fiveDaysKey] = [
      EventEntity(
        id: 'month-5',
        title: 'Sprint Review',
        date: fiveDaysLater,
        startTime: DateTime(fiveDaysLater.year, fiveDaysLater.month, fiveDaysLater.day, 15, 0),
        endTime: DateTime(fiveDaysLater.year, fiveDaysLater.month, fiveDaysLater.day, 16, 0),
        calendarId: 'sprint',
        createdAt: now,
        updatedAt: now,
      ),
      EventEntity(
        id: 'month-6',
        title: 'Design Review',
        date: fiveDaysLater,
        startTime: DateTime(fiveDaysLater.year, fiveDaysLater.month, fiveDaysLater.day, 16, 0),
        endTime: DateTime(fiveDaysLater.year, fiveDaysLater.month, fiveDaysLater.day, 17, 0),
        calendarId: 'design',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    return result;
  }

  /// Day/3-Day View용 Mock 이벤트
  Map<String, List<EventEntity>> _buildMockEvents(List<DateTime> days) {
    final result = <String, List<EventEntity>>{};
    final now = DateTime.now();

    for (final day in days) {
      final key = _dateKey(day);
      final events = <EventEntity>[];

      if (day.year == now.year &&
          day.month == now.month &&
          day.day == now.day) {
        events.addAll([
          EventEntity(
            id: 'mock-1',
            title: 'Sprint Planning',
            date: day,
            startTime: DateTime(day.year, day.month, day.day, 9, 0),
            endTime: DateTime(day.year, day.month, day.day, 10, 0),
            calendarId: 'sprint',
            createdAt: now,
            updatedAt: now,
          ),
          EventEntity(
            id: 'mock-2',
            title: 'Design Sync',
            date: day,
            startTime: DateTime(day.year, day.month, day.day, 10, 0),
            endTime: DateTime(day.year, day.month, day.day, 11, 0),
            calendarId: 'design',
            createdAt: now,
            updatedAt: now,
          ),
          EventEntity(
            id: 'mock-3',
            title: 'Deep Work: UI Phase 2',
            date: day,
            startTime: DateTime(day.year, day.month, day.day, 11, 0),
            endTime: DateTime(day.year, day.month, day.day, 12, 30),
            calendarId: 'deepwork',
            createdAt: now,
            updatedAt: now,
          ),
        ]);
      }

      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      if (day.year == tomorrow.year &&
          day.month == tomorrow.month &&
          day.day == tomorrow.day) {
        events.add(
          EventEntity(
            id: 'mock-4',
            title: 'Team Standup',
            date: day,
            startTime: DateTime(day.year, day.month, day.day, 9, 30),
            endTime: DateTime(day.year, day.month, day.day, 10, 0),
            calendarId: 'standup',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      result[key] = events;
    }

    return result;
  }
}
