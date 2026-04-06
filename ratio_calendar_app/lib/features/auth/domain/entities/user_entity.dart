import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

/// 사용자 엔티티
///
/// Firebase Auth 기반 사용자 정보
/// Firestore: users/{userId}
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required String defaultWorkspaceId,
    required DateTime createdAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}
