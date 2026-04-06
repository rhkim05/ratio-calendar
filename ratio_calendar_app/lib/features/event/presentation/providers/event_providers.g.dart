// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventDetailHash() => r'75bba84d72791e05462cc45d2fae84531d78d709';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 특정 이벤트 조회
///
/// Copied from [eventDetail].
@ProviderFor(eventDetail)
const eventDetailProvider = EventDetailFamily();

/// 특정 이벤트 조회
///
/// Copied from [eventDetail].
class EventDetailFamily extends Family<AsyncValue<EventEntity?>> {
  /// 특정 이벤트 조회
  ///
  /// Copied from [eventDetail].
  const EventDetailFamily();

  /// 특정 이벤트 조회
  ///
  /// Copied from [eventDetail].
  EventDetailProvider call(
    String eventId,
  ) {
    return EventDetailProvider(
      eventId,
    );
  }

  @override
  EventDetailProvider getProviderOverride(
    covariant EventDetailProvider provider,
  ) {
    return call(
      provider.eventId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'eventDetailProvider';
}

/// 특정 이벤트 조회
///
/// Copied from [eventDetail].
class EventDetailProvider extends AutoDisposeFutureProvider<EventEntity?> {
  /// 특정 이벤트 조회
  ///
  /// Copied from [eventDetail].
  EventDetailProvider(
    String eventId,
  ) : this._internal(
          (ref) => eventDetail(
            ref as EventDetailRef,
            eventId,
          ),
          from: eventDetailProvider,
          name: r'eventDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$eventDetailHash,
          dependencies: EventDetailFamily._dependencies,
          allTransitiveDependencies:
              EventDetailFamily._allTransitiveDependencies,
          eventId: eventId,
        );

  EventDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventId,
  }) : super.internal();

  final String eventId;

  @override
  Override overrideWith(
    FutureOr<EventEntity?> Function(EventDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventDetailProvider._internal(
        (ref) => create(ref as EventDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventId: eventId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EventEntity?> createElement() {
    return _EventDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventDetailProvider && other.eventId == eventId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EventDetailRef on AutoDisposeFutureProviderRef<EventEntity?> {
  /// The parameter `eventId` of this provider.
  String get eventId;
}

class _EventDetailProviderElement
    extends AutoDisposeFutureProviderElement<EventEntity?> with EventDetailRef {
  _EventDetailProviderElement(super.provider);

  @override
  String get eventId => (origin as EventDetailProvider).eventId;
}

String _$eventsByDateRangeHash() => r'5e0cbb6e66ab1ccbb06167763651659cd2159a8b';

/// 날짜 범위 기준 이벤트 목록
///
/// Copied from [eventsByDateRange].
@ProviderFor(eventsByDateRange)
const eventsByDateRangeProvider = EventsByDateRangeFamily();

/// 날짜 범위 기준 이벤트 목록
///
/// Copied from [eventsByDateRange].
class EventsByDateRangeFamily extends Family<AsyncValue<List<EventEntity>>> {
  /// 날짜 범위 기준 이벤트 목록
  ///
  /// Copied from [eventsByDateRange].
  const EventsByDateRangeFamily();

  /// 날짜 범위 기준 이벤트 목록
  ///
  /// Copied from [eventsByDateRange].
  EventsByDateRangeProvider call({
    required DateTime start,
    required DateTime end,
  }) {
    return EventsByDateRangeProvider(
      start: start,
      end: end,
    );
  }

  @override
  EventsByDateRangeProvider getProviderOverride(
    covariant EventsByDateRangeProvider provider,
  ) {
    return call(
      start: provider.start,
      end: provider.end,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'eventsByDateRangeProvider';
}

/// 날짜 범위 기준 이벤트 목록
///
/// Copied from [eventsByDateRange].
class EventsByDateRangeProvider
    extends AutoDisposeFutureProvider<List<EventEntity>> {
  /// 날짜 범위 기준 이벤트 목록
  ///
  /// Copied from [eventsByDateRange].
  EventsByDateRangeProvider({
    required DateTime start,
    required DateTime end,
  }) : this._internal(
          (ref) => eventsByDateRange(
            ref as EventsByDateRangeRef,
            start: start,
            end: end,
          ),
          from: eventsByDateRangeProvider,
          name: r'eventsByDateRangeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$eventsByDateRangeHash,
          dependencies: EventsByDateRangeFamily._dependencies,
          allTransitiveDependencies:
              EventsByDateRangeFamily._allTransitiveDependencies,
          start: start,
          end: end,
        );

  EventsByDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<List<EventEntity>> Function(EventsByDateRangeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventsByDateRangeProvider._internal(
        (ref) => create(ref as EventsByDateRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<EventEntity>> createElement() {
    return _EventsByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsByDateRangeProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EventsByDateRangeRef on AutoDisposeFutureProviderRef<List<EventEntity>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _EventsByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<EventEntity>>
    with EventsByDateRangeRef {
  _EventsByDateRangeProviderElement(super.provider);

  @override
  DateTime get start => (origin as EventsByDateRangeProvider).start;
  @override
  DateTime get end => (origin as EventsByDateRangeProvider).end;
}

String _$eventFormIsValidHash() => r'8902b7f75e3c125f80f9e39c247974be7497131a';

/// 폼 유효성 검사
///
/// Copied from [eventFormIsValid].
@ProviderFor(eventFormIsValid)
final eventFormIsValidProvider = AutoDisposeProvider<bool>.internal(
  eventFormIsValid,
  name: r'eventFormIsValidProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventFormIsValidHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventFormIsValidRef = AutoDisposeProviderRef<bool>;
String _$eventFormHash() => r'3dc161056830829938fa0f36c8d0f44df90e105e';

/// 이벤트 생성/수정 폼 상태
///
/// Copied from [EventForm].
@ProviderFor(EventForm)
final eventFormProvider =
    AutoDisposeNotifierProvider<EventForm, EventFormState>.internal(
  EventForm.new,
  name: r'eventFormProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$eventFormHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EventForm = AutoDisposeNotifier<EventFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
