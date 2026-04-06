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
String _$currentViewTypeHash() => r'04afe5706c8e6199a7bebcdcbbab72d39098b8c4';

/// 현재 캘린더 뷰 타입 (Settings의 Default View를 초기값으로 사용)
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
String _$visibleDateRangeHash() => r'11ef720ee0026351772d6ef3b4ebb1f61bad1d41';

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
String _$hourHeightHash() => r'2b293b0a881d34cd43a3d57df321c572f265eacf';

/// 타임라인 1시간 블록 높이 (px)
/// 핀치 줌으로 30 ~ 150 범위에서 동적 조절
/// Day View, 3-Day View 모두 공유
///
/// Copied from [HourHeight].
@ProviderFor(HourHeight)
final hourHeightProvider =
    AutoDisposeNotifierProvider<HourHeight, double>.internal(
  HourHeight.new,
  name: r'hourHeightProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hourHeightHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HourHeight = AutoDisposeNotifier<double>;
String _$goToTodayTriggerHash() => r'e6598015b1d39698bea4113fe033389e00f24aa4';

/// Today 버튼 탭 시 스크롤 애니메이션 트리거
/// 값이 변경될 때마다 타임라인이 현재 시각으로 스크롤
///
/// Copied from [GoToTodayTrigger].
@ProviderFor(GoToTodayTrigger)
final goToTodayTriggerProvider =
    AutoDisposeNotifierProvider<GoToTodayTrigger, int>.internal(
  GoToTodayTrigger.new,
  name: r'goToTodayTriggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goToTodayTriggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GoToTodayTrigger = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
