// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$visibleCalendarsHash() => r'e44e536c43baf9fd578faf02a2d8f8b1384a13f7';

/// 토글이 켜진 캘린더만 필터링
///
/// Copied from [visibleCalendars].
@ProviderFor(visibleCalendars)
final visibleCalendarsProvider =
    AutoDisposeProvider<List<CalendarEntity>>.internal(
  visibleCalendars,
  name: r'visibleCalendarsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$visibleCalendarsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VisibleCalendarsRef = AutoDisposeProviderRef<List<CalendarEntity>>;
String _$currentViewTypeHash() => r'5dc447a3bf50aff50886bd4b9bc488e97f21af8d';

/// 현재 캘린더 뷰 타입 (기본: 3-Day)
///
/// Copied from [CurrentViewType].
@ProviderFor(CurrentViewType)
final currentViewTypeProvider =
    AutoDisposeNotifierProvider<CurrentViewType, CalendarViewType>.internal(
  CurrentViewType.new,
  name: r'currentViewTypeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentViewTypeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentViewType = AutoDisposeNotifier<CalendarViewType>;
String _$selectedDateHash() => r'3d09875b46096499b963f2f58f372e58c537f139';

/// 현재 선택된 날짜
///
/// Copied from [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
  SelectedDate.new,
  name: r'selectedDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
String _$visibleDateRangeHash() => r'40bf9697e2dce60a49e1b42d2bff2ada53c19936';

/// 현재 화면에 표시 중인 날짜 범위
///
/// Copied from [VisibleDateRange].
@ProviderFor(VisibleDateRange)
final visibleDateRangeProvider = AutoDisposeNotifierProvider<VisibleDateRange,
    ({DateTime start, DateTime end})>.internal(
  VisibleDateRange.new,
  name: r'visibleDateRangeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$visibleDateRangeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VisibleDateRange
    = AutoDisposeNotifier<({DateTime start, DateTime end})>;
String _$calendarListHash() => r'bec555920ae27524461b4145f6f3b0ec17886f0d';

/// 사용자의 모든 캘린더 목록
///
/// Copied from [CalendarList].
@ProviderFor(CalendarList)
final calendarListProvider = AutoDisposeNotifierProvider<CalendarList,
    AsyncValue<List<CalendarEntity>>>.internal(
  CalendarList.new,
  name: r'calendarListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$calendarListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarList = AutoDisposeNotifier<AsyncValue<List<CalendarEntity>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
