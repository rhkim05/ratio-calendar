import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace_entity.freezed.dart';
part 'workspace_entity.g.dart';

/// 워크스페이스 엔티티
///
/// Firestore: workspaces/{workspaceId}
@freezed
class WorkspaceEntity with _$WorkspaceEntity {
  const factory WorkspaceEntity({
    required String id,
    required String name,
    required String ownerId,
    @Default([]) List<String> members,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WorkspaceEntity;

  factory WorkspaceEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceEntityFromJson(json);
}
