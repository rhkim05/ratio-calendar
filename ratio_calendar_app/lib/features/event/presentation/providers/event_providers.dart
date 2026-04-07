import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';
import 'package:ratio_calendar/features/event/domain/repositories/event_repository.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:ratio_calendar/features/settings/presentation/providers/settings_providers.dart';

part 'event_providers.g.dart';

// ── Repository Provider ──

/// EventRepository는 main.dart에서 override로 주입
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  throw UnimplementedError('eventRepositoryProvider must be overridden');
});

// ── 이벤트 상태 관리 (Isar 기반) ──

/// Isar에서 모든 이벤트를 로드하고 CRUD 시 즉시 반영
final localEventsProvider =
    AsyncNotifierProvider<LocalEventsNotifier, List<EventEntity>>(
  LocalEventsNotifier.new,
);

class LocalEventsNotifier extends AsyncNotifier<List<EventEntity>> {
  @override
  Future<List<EventEntity>> build() async {
    final repo = ref.watch(eventRepositoryProvider);
    return repo.getAllEvents();
  }

  Future<void> add(EventEntity event) async {
    final repo = ref.read(eventRepositoryProvider);
    await repo.createEvent(event);
    state = AsyncValue.data(<EventEntity>[
      ...(state.valueOrNull ?? []),
      event,
    ]);
  }

  Future<void> remove(String eventId) async {
    final repo = ref.read(eventRepositoryProvider);
    await repo.deleteEvent(eventId);
    final current = state.valueOrNull ?? <EventEntity>[];
    state = AsyncValue.data(
      current.where((e) => e.id != eventId).toList(),
    );
  }

  Future<void> edit(EventEntity updated) async {
    final repo = ref.read(eventRepositoryProvider);
    await repo.updateEvent(updated);
    final current = state.valueOrNull ?? <EventEntity>[];
    state = AsyncValue.data(<EventEntity>[
      for (final e in current)
        if (e.id == updated.id) updated else e,
    ]);
  }
}

/// 날짜 기준으로 이벤트를 그룹핑하는 Provider (비활성 캘린더 이벤트 제외)
final localEventsByDateProvider =
    Provider<Map<String, List<EventEntity>>>((ref) {
  final eventsAsync = ref.watch(localEventsProvider);
  final events = eventsAsync.valueOrNull ?? [];
  final isCalendarLoading = ref.watch(calendarLoadingProvider);
  final visibleIds = ref.watch(visibleCalendarIdsProvider);
  final map = <String, List<EventEntity>>{};

  // 캘린더 로딩 중이면 모든 이벤트 표시 (로딩 완료 전 깜빡임 방지)
  // 로딩 완료 후 visibleIds가 비어있으면 모든 이벤트 숨김
  if (!isCalendarLoading && visibleIds.isEmpty) return map;

  for (final event in events) {
    if (!isCalendarLoading && !visibleIds.contains(event.calendarId)) {
      continue;
    }
    final key =
        '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}';
    map.putIfAbsent(key, () => []).add(event);
  }
  return map;
});

// ── 이벤트 CRUD ──

/// 특정 이벤트 조회
@riverpod
Future<EventEntity?> eventDetail(EventDetailRef ref, String eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventById(eventId);
}

/// 날짜 범위 기준 이벤트 목록
@riverpod
Future<List<EventEntity>> eventsByDateRange(
  EventsByDateRangeRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventsByDateRange(start, end);
}

// ── 폼 상태 ──

/// 이벤트 생성/수정 폼 상태
@riverpod
class EventForm extends _$EventForm {
  @override
  EventFormState build() {
    final defaultAlert = ref.read(settingsProvider).defaultReminderTime;
    return EventFormState(alert: defaultAlert);
  }

  void updateTitle(String title) =>
      state = state.copyWith(title: title);

  void updateDate(DateTime date) =>
      state = state.copyWith(date: date);

  void updateStartTime(DateTime time) =>
      state = state.copyWith(startTime: time);

  void updateEndTime(DateTime time) =>
      state = state.copyWith(endTime: time);

  void updateRecurrence(RecurrenceType recurrence) =>
      state = state.copyWith(recurrence: recurrence);

  void updateAlert(AlertType alert) =>
      state = state.copyWith(alert: alert);

  void updateDescription(String? description) =>
      state = state.copyWith(description: description);

  void updateAttendees(List<String> attendees) =>
      state = state.copyWith(attendees: attendees);

  void updateCalendarId(String calendarId) =>
      state = state.copyWith(calendarId: calendarId);

  void reset() => state = EventFormState();
}

/// 폼 유효성 검사
@riverpod
bool eventFormIsValid(EventFormIsValidRef ref) {
  final form = ref.watch(eventFormProvider);
  return form.title.isNotEmpty &&
      form.calendarId.isNotEmpty &&
      form.startTime != null &&
      form.endTime != null &&
      (form.startTime!.isBefore(form.endTime!));
}

/// 이벤트 폼 상태 클래스
class EventFormState {
  final String title;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final RecurrenceType recurrence;
  final AlertType alert;
  final String? description;
  final List<String> attendees;
  final String calendarId;

  EventFormState({
    this.title = '',
    this.date,
    this.startTime,
    this.endTime,
    this.recurrence = RecurrenceType.never,
    this.alert = AlertType.fifteenMinutes,
    this.description,
    this.attendees = const [],
    this.calendarId = '',
  });

  EventFormState copyWith({
    String? title,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    RecurrenceType? recurrence,
    AlertType? alert,
    String? description,
    List<String>? attendees,
    String? calendarId,
  }) {
    return EventFormState(
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurrence: recurrence ?? this.recurrence,
      alert: alert ?? this.alert,
      description: description ?? this.description,
      attendees: attendees ?? this.attendees,
      calendarId: calendarId ?? this.calendarId,
    );
  }
}
