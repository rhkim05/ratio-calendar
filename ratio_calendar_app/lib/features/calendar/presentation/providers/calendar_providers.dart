import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/features/calendar/domain/entities/calendar_entity.dart';
import 'package:ratio_calendar/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:ratio_calendar/features/settings/presentation/providers/settings_providers.dart';
import 'package:ratio_calendar/features/workspace/presentation/providers/workspace_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_providers.g.dart';

// ── Repository Provider ──

/// CalendarRepository는 main.dart에서 override로 주입
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  throw UnimplementedError('calendarRepositoryProvider must be overridden');
});

// ── 뷰 상태 ──

/// 현재 캘린더 뷰 타입 (Settings의 Default View를 초기값으로 사용)
@riverpod
class CurrentViewType extends _$CurrentViewType {
  @override
  CalendarViewType build() {
    return ref.read(settingsProvider).defaultView;
  }

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
    final viewType = ref.read(currentViewTypeProvider);
    final days = viewType == CalendarViewType.day ? 0 : 2;
    return (start: today, end: today.add(Duration(days: days)));
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

// ── Today 트리거 ──

/// Today 버튼 탭 시 스크롤 애니메이션 트리거
/// 값이 변경될 때마다 타임라인이 현재 시각으로 스크롤
@riverpod
class GoToTodayTrigger extends _$GoToTodayTrigger {
  @override
  int build() => 0;

  void fire() => state++;
}

// ── 데이터 ──

/// 사용자의 모든 캘린더 목록 (Isar에서 로드)
final calendarListProvider =
    AsyncNotifierProvider<CalendarListNotifier, List<CalendarEntity>>(
  CalendarListNotifier.new,
);

class CalendarListNotifier extends AsyncNotifier<List<CalendarEntity>> {
  /// ensureDefaults가 완료된 워크스페이스 ID 캐시
  final _initializedWorkspaces = <String>{};

  @override
  Future<List<CalendarEntity>> build() async {
    final repo = ref.watch(calendarRepositoryProvider);
    final workspaceId = ref.watch(currentWorkspaceIdProvider);
    if (_initializedWorkspaces.add(workspaceId)) {
      await repo.ensureDefaults(workspaceId);
    }
    return repo.getCalendarsByWorkspace(workspaceId);
  }

  Future<void> add(CalendarEntity calendar) async {
    final repo = ref.read(calendarRepositoryProvider);
    await repo.createCalendar(calendar);
    state = AsyncValue.data(<CalendarEntity>[
      ...(state.valueOrNull ?? []),
      calendar,
    ]);
  }

  Future<void> edit(CalendarEntity calendar) async {
    final repo = ref.read(calendarRepositoryProvider);
    await repo.updateCalendar(calendar);
    final current = state.valueOrNull ?? <CalendarEntity>[];
    state = AsyncValue.data(<CalendarEntity>[
      for (final c in current)
        if (c.id == calendar.id) calendar else c,
    ]);
  }

  Future<void> remove(String id) async {
    final repo = ref.read(calendarRepositoryProvider);
    await repo.deleteCalendar(id);
    final current = state.valueOrNull ?? <CalendarEntity>[];
    state = AsyncValue.data(
      current.where((c) => c.id != id).toList(),
    );
  }

  Future<void> toggleVisibility(String id) async {
    final calendars = state.valueOrNull ?? [];
    final target = calendars.firstWhere((c) => c.id == id);
    final updated = target.copyWith(
      isVisible: !target.isVisible,
      updatedAt: DateTime.now(),
    );
    await edit(updated);
  }
}

/// 토글이 켜진 캘린더만 필터링
@riverpod
List<CalendarEntity> visibleCalendars(VisibleCalendarsRef ref) {
  final calendars = ref.watch(calendarListProvider);
  return calendars.whenOrNull(
        data: (list) => list.where((c) => c.isVisible).toList(),
      ) ??
      [];
}

/// 캘린더 목록 로딩 중 여부
final calendarLoadingProvider = Provider<bool>((ref) {
  final calendars = ref.watch(calendarListProvider);
  return calendars.isLoading;
});

/// 토글이 켜진 캘린더의 ID 목록 (이벤트 필터링용)
final visibleCalendarIdsProvider = Provider<Set<String>>((ref) {
  final calendars = ref.watch(calendarListProvider);
  final list = calendars.valueOrNull ?? <CalendarEntity>[];
  return list.where((c) => c.isVisible).map((c) => c.id).toSet();
});
