import 'package:ratio_calendar/features/calendar/domain/entities/calendar_entity.dart';

/// CalendarEntity ↔ SQLite Map 변환 유틸
class CalendarDbConverter {
  CalendarDbConverter._();

  /// Domain Entity → SQLite Map
  static Map<String, dynamic> toMap(CalendarEntity entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'color_hex': entity.colorHex,
      'is_visible': entity.isVisible ? 1 : 0,
      'workspace_id': entity.workspaceId,
      'created_at': entity.createdAt.millisecondsSinceEpoch,
      'updated_at': entity.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// SQLite Map → Domain Entity
  static CalendarEntity fromMap(Map<String, dynamic> map) {
    return CalendarEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      isVisible: (map['is_visible'] as int) == 1,
      workspaceId: map['workspace_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
