// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalendarEntity _$CalendarEntityFromJson(Map<String, dynamic> json) {
  return _CalendarEntity.fromJson(json);
}

/// @nodoc
mixin _$CalendarEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  bool get isVisible => throw _privateConstructorUsedError;
  String get workspaceId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CalendarEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEntityCopyWith<CalendarEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEntityCopyWith<$Res> {
  factory $CalendarEntityCopyWith(
          CalendarEntity value, $Res Function(CalendarEntity) then) =
      _$CalendarEntityCopyWithImpl<$Res, CalendarEntity>;
  @useResult
  $Res call(
      {String id,
      String name,
      String colorHex,
      bool isVisible,
      String workspaceId,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$CalendarEntityCopyWithImpl<$Res, $Val extends CalendarEntity>
    implements $CalendarEntityCopyWith<$Res> {
  _$CalendarEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorHex = null,
    Object? isVisible = null,
    Object? workspaceId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      colorHex: null == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      workspaceId: null == workspaceId
          ? _value.workspaceId
          : workspaceId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarEntityImplCopyWith<$Res>
    implements $CalendarEntityCopyWith<$Res> {
  factory _$$CalendarEntityImplCopyWith(_$CalendarEntityImpl value,
          $Res Function(_$CalendarEntityImpl) then) =
      __$$CalendarEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String colorHex,
      bool isVisible,
      String workspaceId,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$CalendarEntityImplCopyWithImpl<$Res>
    extends _$CalendarEntityCopyWithImpl<$Res, _$CalendarEntityImpl>
    implements _$$CalendarEntityImplCopyWith<$Res> {
  __$$CalendarEntityImplCopyWithImpl(
      _$CalendarEntityImpl _value, $Res Function(_$CalendarEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalendarEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorHex = null,
    Object? isVisible = null,
    Object? workspaceId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$CalendarEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      colorHex: null == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      workspaceId: null == workspaceId
          ? _value.workspaceId
          : workspaceId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEntityImpl implements _CalendarEntity {
  const _$CalendarEntityImpl(
      {required this.id,
      required this.name,
      this.colorHex = '#007AFF',
      this.isVisible = true,
      required this.workspaceId,
      required this.createdAt,
      required this.updatedAt});

  factory _$CalendarEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String colorHex;
  @override
  @JsonKey()
  final bool isVisible;
  @override
  final String workspaceId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CalendarEntity(id: $id, name: $name, colorHex: $colorHex, isVisible: $isVisible, workspaceId: $workspaceId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.workspaceId, workspaceId) ||
                other.workspaceId == workspaceId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, colorHex, isVisible,
      workspaceId, createdAt, updatedAt);

  /// Create a copy of CalendarEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEntityImplCopyWith<_$CalendarEntityImpl> get copyWith =>
      __$$CalendarEntityImplCopyWithImpl<_$CalendarEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEntityImplToJson(
      this,
    );
  }
}

abstract class _CalendarEntity implements CalendarEntity {
  const factory _CalendarEntity(
      {required final String id,
      required final String name,
      final String colorHex,
      final bool isVisible,
      required final String workspaceId,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$CalendarEntityImpl;

  factory _CalendarEntity.fromJson(Map<String, dynamic> json) =
      _$CalendarEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get colorHex;
  @override
  bool get isVisible;
  @override
  String get workspaceId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CalendarEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEntityImplCopyWith<_$CalendarEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
