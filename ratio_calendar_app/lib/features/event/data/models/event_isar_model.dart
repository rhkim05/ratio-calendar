import 'dart:convert';

import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// EventEntity ↔ SQLite Map 변환 유틸
class EventDbConverter {
  EventDbConverter._();

  /// Domain Entity → SQLite Map
  static Map<String, dynamic> toMap(EventEntity entity) {
    return {
      'id': entity.id,
      'title': entity.title,
      'date': entity.date.millisecondsSinceEpoch,
      'start_time': entity.startTime.millisecondsSinceEpoch,
      'end_time': entity.endTime.millisecondsSinceEpoch,
      'recurrence': entity.recurrence.index,
      'alert': entity.alert.index,
      'description': entity.description,
      'attendees': jsonEncode(entity.attendees),
      'calendar_id': entity.calendarId,
      'created_at': entity.createdAt.millisecondsSinceEpoch,
      'updated_at': entity.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// SQLite Map → Domain Entity
  static EventEntity fromMap(Map<String, dynamic> map) {
    return EventEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      recurrence: RecurrenceType.values[map['recurrence'] as int],
      alert: AlertType.values[map['alert'] as int],
      description: map['description'] as String?,
      attendees: (jsonDecode(map['attendees'] as String) as List)
          .cast<String>(),
      calendarId: map['calendar_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
