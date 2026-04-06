// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventEntityImpl _$$EventEntityImplFromJson(Map<String, dynamic> json) =>
    _$EventEntityImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      recurrence:
          $enumDecodeNullable(_$RecurrenceTypeEnumMap, json['recurrence']) ??
              RecurrenceType.never,
      alert: $enumDecodeNullable(_$AlertTypeEnumMap, json['alert']) ??
          AlertType.fifteenMinutes,
      description: json['description'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      calendarId: json['calendarId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$EventEntityImplToJson(_$EventEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'recurrence': _$RecurrenceTypeEnumMap[instance.recurrence]!,
      'alert': _$AlertTypeEnumMap[instance.alert]!,
      'description': instance.description,
      'attendees': instance.attendees,
      'calendarId': instance.calendarId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.never: 'never',
  RecurrenceType.daily: 'daily',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.monthly: 'monthly',
  RecurrenceType.yearly: 'yearly',
  RecurrenceType.custom: 'custom',
};

const _$AlertTypeEnumMap = {
  AlertType.none: 'none',
  AlertType.fiveMinutes: 'fiveMinutes',
  AlertType.fifteenMinutes: 'fifteenMinutes',
  AlertType.thirtyMinutes: 'thirtyMinutes',
  AlertType.oneHour: 'oneHour',
  AlertType.oneDay: 'oneDay',
};
