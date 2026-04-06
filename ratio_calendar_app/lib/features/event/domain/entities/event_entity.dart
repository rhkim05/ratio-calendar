import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ratio_calendar/core/constants/enums.dart';

part 'event_entity.freezed.dart';
part 'event_entity.g.dart';

/// 이벤트(일정) 엔티티
/// 캘린더에 속하는 개별 일정
///
/// Firestore: workspaces/{workspaceId}/calendars/{calendarId}/events/{eventId}
@freezed
class EventEntity with _$EventEntity {
  const factory EventEntity({
    required String id,
    required String title,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    @Default(RecurrenceType.never) RecurrenceType recurrence,
    @Default(AlertType.fifteenMinutes) AlertType alert,
    String? description,
    @Default([]) List<String> attendees,
    required String calendarId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EventEntity;

  factory EventEntity.fromJson(Map<String, dynamic> json) =>
      _$EventEntityFromJson(json);
}
