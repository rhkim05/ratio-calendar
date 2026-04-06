import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_entity.freezed.dart';
part 'calendar_entity.g.dart';

/// 캘린더 엔티티
/// 사용자가 만든 캘린더 (Personal, Work, Shared 등)
///
/// Firestore: workspaces/{workspaceId}/calendars/{calendarId}
@freezed
class CalendarEntity with _$CalendarEntity {
  const factory CalendarEntity({
    required String id,
    required String name,
    @Default('#007AFF') String colorHex,
    @Default(true) bool isVisible,
    required String workspaceId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarEntity;

  factory CalendarEntity.fromJson(Map<String, dynamic> json) =>
      _$CalendarEntityFromJson(json);
}
