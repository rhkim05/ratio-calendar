import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/features/calendar/domain/entities/calendar_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_providers.g.dart';

// ── 뷰 상태 ──

/// 현재 캘린더 뷰 타입 (기본: 3-Day)
@riverpod
class CurrentViewType extends _$CurrentViewType {
  @override
  CalendarViewType build() => CalendarViewType.threeDay;

  void change(CalendarViewType type) {
    state = type;
    // 뷰 전환 시 visibleDateRange도 함께 업데이트
    final selectedDate = ref.read(selectedDateProvider);
    final today = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final range = ref.read(visibleDateRangeProvider.notifier);
    switch (type) {
      case CalendarViewType.day:
        range.update(start: today, end: today);
      case CalendarViewType.threeDay:
        range.update(start: today, end: today.add(const Duration(days: 2)));
      default:
        break;
    }
  }
}

/// 현재 선택된 날짜
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

/// 현재 화면에 표시 중인 날짜 범위
@riverpod
class VisibleDateRange extends _$VisibleDateRange {
  @override
  ({DateTime start, DateTime end}) build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (start: today, end: today.add(const Duration(days: 2)));
  }

  void update({required DateTime start, required DateTime end}) =>
      state = (start: start, end: end);
}

// ── 타임라인 줌 ──

/// 타임라인 1시간 블록 높이 (px)
/// 핀치 줌으로 30 ~ 150 범위에서 동적 조절
/// Day View, 3-Day View 모두 공유
@riverpod
class HourHeight extends _$HourHeight {
  static const double minHeight = 30.0;
  static const double maxHeight = 150.0;
  static const double defaultHeight = 60.0;

  @override
  double build() => defaultHeight;

  void set(double value) {
    state = value.clamp(minHeight, maxHeight);
  }
}

// ── 데이터 ──

/// 사용자의 모든 캘린더 목록
@riverpod
class CalendarList extends _$CalendarList {
  @override
  AsyncValue<List<CalendarEntity>> build() => const AsyncValue.loading();

  // TODO: Repository 연결 후 Firestore에서 로드
}

/// 토글이 켜진 캘린더만 필터링
@riverpod
List<CalendarEntity> visibleCalendars(VisibleCalendarsRef ref) {
  final calendars = ref.watch(calendarListProvider);
  return calendars.whenOrNull(data: (list) => list.where((c) => c.isVisible).toList()) ?? [];
}
