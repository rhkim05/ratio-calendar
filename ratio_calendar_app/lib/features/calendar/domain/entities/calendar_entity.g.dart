// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarEntityImpl _$$CalendarEntityImplFromJson(Map<String, dynamic> json) =>
    _$CalendarEntityImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['colorHex'] as String? ?? '#007AFF',
      isVisible: json['isVisible'] as bool? ?? true,
      workspaceId: json['workspaceId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CalendarEntityImplToJson(
        _$CalendarEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'colorHex': instance.colorHex,
      'isVisible': instance.isVisible,
      'workspaceId': instance.workspaceId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
