import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

part 'event_providers.g.dart';

// ── 로컬 이벤트 저장소 (Firestore 연동 전 임시) ──

/// 로컬 메모리에 이벤트를 저장하는 Provider
final localEventsProvider =
    NotifierProvider<LocalEventsNotifier, List<EventEntity>>(
  LocalEventsNotifier.new,
);

class LocalEventsNotifier extends Notifier<List<EventEntity>> {
  @override
  List<EventEntity> build() => [];

  void add(EventEntity event) {
    state = [...state, event];
  }

  void remove(String eventId) {
    state = state.where((e) => e.id != eventId).toList();
  }

  void update(EventEntity updated) {
    state = [
      for (final e in state)
        if (e.id == updated.id) updated else e,
    ];
  }
}

/// 날짜 기준으로 로컬 이벤트를 그룹핑하는 Provider
final localEventsByDateProvider =
    Provider<Map<String, List<EventEntity>>>((ref) {
  final events = ref.watch(localEventsProvider);
  final map = <String, List<EventEntity>>{};
  for (final event in events) {
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
  // TODO: Repository 연결 후 Firestore에서 로드
  return null;
}

/// 날짜 범위 기준 이벤트 목록
@riverpod
Future<List<EventEntity>> eventsByDateRange(
  EventsByDateRangeRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  // TODO: Repository 연결 후 Firestore에서 로드
  return [];
}

// ── 폼 상태 ──

/// 이벤트 생성/수정 폼 상태
@riverpod
class EventForm extends _$EventForm {
  @override
  EventFormState build() => EventFormState();

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
