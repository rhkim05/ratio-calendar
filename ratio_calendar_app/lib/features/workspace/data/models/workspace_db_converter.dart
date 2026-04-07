import 'dart:convert';

import 'package:ratio_calendar/features/workspace/domain/entities/workspace_entity.dart';

/// WorkspaceEntity ↔ SQLite Map 변환 유틸
class WorkspaceDbConverter {
  WorkspaceDbConverter._();

  static Map<String, dynamic> toMap(WorkspaceEntity entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'owner_id': entity.ownerId,
      'members': jsonEncode(entity.members),
      'created_at': entity.createdAt.millisecondsSinceEpoch,
      'updated_at': entity.updatedAt.millisecondsSinceEpoch,
    };
  }

  static WorkspaceEntity fromMap(Map<String, dynamic> map) {
    return WorkspaceEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      ownerId: map['owner_id'] as String,
      members: (jsonDecode(map['members'] as String) as List).cast<String>(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
