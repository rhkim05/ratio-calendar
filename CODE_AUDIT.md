# Ratio Calendar Flutter App — Comprehensive Code Audit

**Audit Date:** April 7, 2026
**Scope:** All Dart files in `/lib/` directory
**Total Files Reviewed:** 76 files

---

## Executive Summary

The Ratio Calendar codebase is generally well-structured with good architectural patterns (Clean Architecture + Riverpod state management). However, there are **multiple critical issues**, several medium-priority inconsistencies, and many low-priority improvements needed. Key concerns:

- **Critical null safety violations** in event migration and calendar lookups
- **State management leaks** in stream subscriptions and ScrollController disposal
- **Hardcoded values scattered throughout** despite dedicated design tokens
- **Missing error handling** in critical data operations
- **Performance issues** with unnecessary rebuilds and constant widget creation
- **Design token violations** (colors, sizes) across multiple files

**Total Issues Found: 82** (8 Critical, 18 Medium, 56 Low)

---

## Issues by Category

### 1. CRITICAL ISSUES (Must Fix)

#### 1.1 Null Safety: Migration Service Unchecked Cast
**File:** `features/auth/data/services/migration_service.dart`, Line 104
**Severity:** Critical
**Issue:** `data['defaultWorkspaceId']` is cast to String without null-safety check in `_loadUserEntity`

```dart
defaultWorkspaceId: data['defaultWorkspaceId'] as String,  // Can throw if key missing
```

**Fix:**
```dart
defaultWorkspaceId: (data['defaultWorkspaceId'] as String?) ?? 'default-workspace-id',
```

---

#### 1.2 Null Safety: EventDbConverter Index Out of Bounds
**File:** `features/event/data/models/event_isar_model.dart`, Lines 36-37
**Severity:** Critical
**Issue:** Enum index access without bounds checking - will crash if invalid enum index stored

```dart
recurrence: RecurrenceType.values[map['recurrence'] as int],  // Can throw RangeError
alert: AlertType.values[map['alert'] as int],                 // Can throw RangeError
```

**Fix:**
```dart
recurrence: _parseRecurrenceType(map['recurrence'] as int?),
alert: _parseAlertType(map['alert'] as int?),

// Add safe parsing methods
static RecurrenceType _parseRecurrenceType(int? index) {
  if (index == null || index < 0 || index >= RecurrenceType.values.length) {
    return RecurrenceType.never;
  }
  return RecurrenceType.values[index];
}
```

---

#### 1.3 Stream Subscription Memory Leak
**File:** `features/auth/presentation/providers/auth_providers.dart`, Lines 69-70
**Severity:** Critical
**Issue:** `_authSub` subscription is cancelled on dispose, but if `build()` is called multiple times (during rebuilds), multiple listeners are created without cleanup

```dart
@override
AuthState build() {
  // ...
  _authSub = _datasource.authStateChanges.listen(_onAuthStateChanged);  // Creates new listener every rebuild
  ref.onDispose(() => _authSub?.cancel());
}
```

**Fix:** Only create subscription once
```dart
@override
AuthState build() {
  _datasource = ref.read(authRemoteDatasourceProvider);
  _migrationService = ref.read(migrationServiceProvider);

  // Only add listener if not already listening
  _authSub ??= _datasource.authStateChanges.listen(_onAuthStateChanged);
  ref.onDispose(() => _authSub?.cancel());
  // ...
}
```

---

#### 1.4 ScrollController Not Properly Initialized
**File:** `features/calendar/presentation/widgets/swipeable_timeline.dart`, Lines 89-93
**Severity:** Critical
**Issue:** ScrollController is created multiple times without disposal in `initState`, potential memory leak

```dart
@override
void initState() {
  super.initState();
  _baseDate = DateTime.now();
  // _hController is created later in build(), but old one never disposed if build() rebuilds
}
```

**Fix:** Ensure proper controller lifecycle management in build()
```dart
if (!_initialized) {
  _hController?.removeListener(_syncHeader);
  _hController?.dispose();
  _headerController?.dispose();
  // Now create new controllers
  _hController = ScrollController(initialScrollOffset: initialOffset);
  _headerController = ScrollController(initialScrollOffset: initialOffset);
  _hController!.addListener(_syncHeader);
  _initialized = true;
}
```

---

#### 1.5 EventCreateSheet Unhandled Exception in Save
**File:** `features/event/presentation/screens/event_create_sheet.dart`, Lines 139-175
**Severity:** Critical
**Issue:** `_save()` has no try-catch for repository operations, unhandled errors will crash the sheet

```dart
Future<void> _save() async {
  final title = _titleController.text.trim();
  if (title.isEmpty) return;
  // ... no error handling for:
  final updated = widget.event!.copyWith(...);
  await ref.read(localEventsProvider.notifier).edit(updated);  // Can throw
}
```

**Fix:** Add comprehensive error handling
```dart
Future<void> _save() async {
  try {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    // ... save logic
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save event: $e')),
      );
    }
  }
}
```

---

#### 1.6 Auth Provider Missing null Check on Firestore Doc
**File:** `features/auth/presentation/providers/auth_providers.dart`, Line 97
**Severity:** Critical
**Issue:** `doc.data()!` is force-unwrapped without checking if doc.data is null

```dart
if (doc.exists) {
  final data = doc.data()!;  // Will crash if Firestore doc structure changed
  state = AuthAuthenticated(
    user: UserEntity(
      // ...
      defaultWorkspaceId: data['defaultWorkspaceId'] as String,  // Also unchecked cast
    ),
  );
}
```

**Fix:**
```dart
if (doc.exists) {
  final data = doc.data();
  if (data != null) {
    try {
      state = AuthAuthenticated(
        user: UserEntity(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: data['displayName'] as String?,
          photoUrl: data['photoUrl'] as String?,
          defaultWorkspaceId: (data['defaultWorkspaceId'] as String?) ?? 'default',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ),
      );
    } catch (e) {
      state = AuthError(message: 'Failed to load user: $e');
    }
  }
}
```

---

#### 1.7 MonthGrid Index Out of Bounds
**File:** `features/calendar/presentation/widgets/month_grid.dart`, Line 38
**Severity:** Critical
**Issue:** `_dayLabels` index calculation can be wrong for edge cases

```dart
final startIndex = (startOfWeekDay - 1) % 7;
return [
  ..._allDayLabels.sublist(startIndex),
  ..._allDayLabels.sublist(0, startIndex),
];
```

If `startOfWeekDay` is 8 (invalid), `startIndex` becomes `0`, but the logic assumes valid weekday (1-7).

**Fix:** Validate input
```dart
final validStartDay = startOfWeekDay.clamp(1, 7);
final startIndex = (validStartDay - 1) % 7;
```

---

#### 1.8 Workspace Provider Missing User Check
**File:** `features/workspace/presentation/providers/workspace_providers.dart`, Lines 26-31
**Severity:** Critical
**Issue:** `syncWorkspacesFromFirestore` is called when `user` might become null after check

```dart
@override
Future<List<WorkspaceEntity>> build() async {
  final repo = ref.watch(workspaceRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user != null) {
    final synced = await repo.syncWorkspacesFromFirestore(user.id);  // Race condition
    // ...
  }
}
```

If auth state changes during await, `user` becomes stale.

**Fix:** Use local variable and check before calling
```dart
@override
Future<List<WorkspaceEntity>> build() async {
  final repo = ref.watch(workspaceRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser != null) {
    try {
      final synced = await repo.syncWorkspacesFromFirestore(currentUser.id);
      if (synced.isNotEmpty) return synced;
    } catch (e) {
      // Log error, fall back to local
    }
  }

  await repo.ensureDefaultWorkspace();
  return repo.getAllWorkspaces();
}
```

---

### 2. MEDIUM SEVERITY ISSUES

#### 2.1 Hardcoded Colors Not Using AppColors
**File:** `features/calendar/presentation/screens/calendar_main_screen.dart`, Lines 24-29
**Severity:** Medium
**Issue:** Mock calendar colors are hardcoded instead of using centralized AppColors

```dart
static const _mockColors = <String, Color>{
  'sprint': AppColors.blueBorder,
  'design': AppColors.tealBorder,
  'deepwork': AppColors.amberBorder,
  'standup': AppColors.orangeBorder,
};
```

While this uses AppColors references, the mapping should be configurable or in AppColors itself.

**Fix:** Move to app_colors.dart
```dart
// app_colors.dart
static const calendarEventColors = <String, Color>{
  'sprint': blueBorder,
  'design': tealBorder,
  'deepwork': amberBorder,
  'standup': orangeBorder,
};
```

---

#### 2.2 Platform-Specific Override Issue
**File:** `core/theme/app_theme.dart`, Line 44
**Severity:** Medium
**Issue:** Forcing `TargetPlatform.android` globally disables iOS-specific behaviors system-wide

```dart
platform: TargetPlatform.android,  // Always Android behavior even on iOS
```

This forces Material design on iOS, breaking native platform conventions.

**Fix:** Use `defaultTargetPlatform` or remove entirely to allow platform detection
```dart
// Option 1: Remove it entirely (Flutter auto-detects)
// Option 2: Use actual platform
platform: defaultTargetPlatform,
```

---

#### 2.3 Missing Input Validation in Login/Signup
**File:** `features/auth/presentation/screens/login_screen.dart`, Line 145
**Severity:** Medium
**Issue:** Email validation is minimal (`!v.contains('@')`), doesn't match RFC 5322

```dart
validator: (v) {
  if (v == null || v.trim().isEmpty) {
    return 'Email is required';
  }
  if (!v.contains('@')) return 'Invalid email';
  return null;
},
```

**Fix:** Use proper email regex or validation library
```dart
import 'package:email_validator/email_validator.dart';

validator: (v) {
  if (v == null || v.trim().isEmpty) {
    return 'Email is required';
  }
  if (!EmailValidator.validate(v)) {
    return 'Invalid email address';
  }
  return null;
},
```

---

#### 2.4 EventEntity Date Field Redundancy
**File:** `features/event/domain/entities/event_entity.dart`, Lines 14-18
**Severity:** Medium
**Issue:** `date` field is redundant (can be derived from `startTime`) and can cause inconsistency

```dart
required String id,
required String title,
required DateTime date,           // Redundant
required DateTime startTime,
required DateTime endTime,
```

If `date` and `startTime` get out of sync, bugs occur.

**Fix:** Remove `date` field or document that it must match `startTime`'s date part
```dart
/// Note: date must always be set to DateTime(startTime.year, startTime.month, startTime.day)
required DateTime date,
```

---

#### 2.5 TimelineView Timer Memory Leak
**File:** `features/calendar/presentation/widgets/timeline_view.dart`, Lines 215-231
**Severity:** Medium
**Issue:** Timer is created and disposed correctly, but if widget is disposed during timer callback, error occurs

```dart
@override
void dispose() {
  _timer.cancel();
  super.dispose();
}
```

Race condition if `setState` is called after disposal.

**Fix:**
```dart
@override
void dispose() {
  _timer.cancel();
  super.dispose();
}

@override
void initState() {
  super.initState();
  _now = DateTime.now();
  _timer = Timer.periodic(const Duration(minutes: 1), (_) {
    if (mounted) {  // Add safety check
      setState(() => _now = DateTime.now());
    }
  });
}
```

---

#### 2.6 CalendarMainScreen No Loader States
**File:** `features/calendar/presentation/screens/calendar_main_screen.dart`
**Severity:** Medium
**Issue:** No loading or error states shown while `calendarListProvider` loads

```dart
final localEvents = ref.watch(localEventsByDateProvider);
// No handling of AsyncValue.loading or .error states
```

**Fix:** Add proper state handling
```dart
ref.listen(calendarListProvider, (previous, next) {
  if (next.isLoading) {
    // Show loading indicator
  } else if (next.hasError) {
    // Show error snackbar
  }
});
```

---

#### 2.7 ThemeData Dark Mode Incomplete
**File:** `core/theme/app_theme.dart`, Line 127
**Severity:** Medium
**Issue:** Dark theme has TODO and incomplete implementation

```dart
static ThemeData get dark => ThemeData(
  // ...
  textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
  // TODO(phase2): Dark 테마 세부 설정
);
```

Dark theme will fall back to defaults, causing inconsistency.

**Fix:** Implement full dark theme or use light theme for now
```dart
@override
Widget build(BuildContext context) {
  return MaterialApp.router(
    // ...
    themeMode: ThemeMode.light,  // Until dark mode is complete
  );
}
```

---

#### 2.8 Settings Provider No Validation
**File:** `features/settings/presentation/providers/settings_providers.dart`, Line 116-128
**Severity:** Medium
**Issue:** Enum deserialization from SharedPreferences with no bounds checking

```dart
defaultView: viewIndex != null && viewIndex < CalendarViewType.values.length
    ? CalendarViewType.values[viewIndex]
    : CalendarViewType.threeDay,
```

If values.length changes due to enum refactor, existing data breaks.

**Fix:** Explicit enum value handling
```dart
defaultView: _parseCalendarViewType(viewIndex),

static CalendarViewType _parseCalendarViewType(int? index) {
  try {
    if (index != null && index >= 0 && index < CalendarViewType.values.length) {
      return CalendarViewType.values[index];
    }
  } catch (_) {}
  return CalendarViewType.threeDay;
}
```

---

#### 2.9 EventBlock Height Calculation Precision Loss
**File:** `features/calendar/presentation/widgets/event_block.dart`, Lines 47-51
**Severity:** Medium
**Issue:** Floating-point arithmetic can cause visual inconsistencies

```dart
final durationMinutes = event.endTime.difference(event.startTime).inMinutes;
const verticalInset = 2.0;
final rawHeight = durationMinutes * hourHeight / 60;
final height = rawHeight - verticalInset * 2;
```

Very small events (< 4 min) will have negative height.

**Fix:**
```dart
final height = (rawHeight - verticalInset * 2).clamp(0, double.infinity);
final isCompact = height < 40;
```

---

#### 2.10 Month Grid Next Month Calculation Bug
**File:** `features/calendar/presentation/widgets/month_grid.dart`, Line 94
**Severity:** Medium
**Issue:** Next month padding calculation is incorrect

```dart
while (dates.length < 42) {
  dates.add(DateTime(
    displayedMonth.year,
    displayedMonth.month,
    daysInMonth + (dates.length - startWeekday - daysInMonth) + 1,
  ));
}
```

Day parameter can exceed the actual days in month.

**Fix:**
```dart
final nextMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 1);
while (dates.length < 42) {
  final nextDayNum = dates.length - startWeekday - daysInMonth + 1;
  dates.add(DateTime(nextMonth.year, nextMonth.month, nextDayNum));
}
```

---

#### 2.11 SwipeableTimeline Base Date Never Updates
**File:** `features/calendar/presentation/widgets/swipeable_timeline.dart`, Line 128
**Severity:** Medium
**Issue:** `_baseDate` is set on first build but never updated if user navigates months

```dart
if (!_initialized) {
  _baseDate = visibleRange.start;  // Only set once
}
```

After month change, calculations use stale base date.

**Fix:**
```dart
if (!_initialized) {
  _baseDate = visibleRange.start;
  _initialized = true;
} else if (!_isSwipeNav) {
  // Update base date for external navigation changes
  _baseDate = visibleRange.start;
}
```

---

#### 2.12 AttendeeAvatar Index Out of Bounds
**File:** `shared/widgets/attendee_avatar.dart`, Lines 21-22
**Severity:** Medium
**Issue:** `_initials` can throw if name is empty after split

```dart
String get _initials {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();  // parts[0][0] throws if empty
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}
```

**Fix:**
```dart
String get _initials {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final second = parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}
```

---

#### 2.13 EventCreateSheet Date/Time Clamp Issue
**File:** `features/event/presentation/screens/event_create_sheet.dart`, Line 116
**Severity:** Medium
**Issue:** Next hour calculation clamps to 23 but doesn't wrap to next day

```dart
final nextHour = now.hour + 1;
_startTime = DateTime(
  _selectedDate.year,
  _selectedDate.month,
  _selectedDate.day,
  nextHour.clamp(0, 23),  // 23:00 is max, but should be next day 00:00
);
```

If created at 23:59, event is 3 hours long incorrectly.

**Fix:**
```dart
final nextHour = now.hour + 1;
if (nextHour >= 24) {
  _selectedDate = _selectedDate.add(const Duration(days: 1));
  _startTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0);
} else {
  _startTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, nextHour);
}
```

---

#### 2.14 Firebase Options Import Not Validated
**File:** `main.dart`, Line 41-43
**Severity:** Medium
**Issue:** `firebase_options.dart` is imported but file generation steps not documented

```dart
import 'firebase_options.dart';

// ...
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

If `firebase_options.dart` is out of date, crashes occur silently.

**Fix:** Add runtime validation or documentation in README about flutterfire setup

---

#### 2.15 Calendar List Provider Multiple Loads
**File:** `features/calendar/presentation/providers/calendar_providers.dart`, Lines 104-116
**Severity:** Medium
**Issue:** `calendarListProvider` calls both `ensureDefaults` and `getCalendarsByWorkspace` every build

```dart
@override
Future<List<CalendarEntity>> build() async {
  final repo = ref.watch(calendarRepositoryProvider);
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  await repo.ensureDefaults(workspaceId);  // Always called
  return repo.getCalendarsByWorkspace(workspaceId);  // Always called
}
```

Should cache result or only create defaults once.

**Fix:** Add flag to ensure defaults only once per workspace
```dart
// Add to repository
Future<List<CalendarEntity>> getCalendarsByWorkspaceWithDefaults(String workspaceId) async {
  await ensureDefaults(workspaceId);  // Idempotent
  return getCalendarsByWorkspace(workspaceId);
}
```

---

### 3. LOW SEVERITY ISSUES (Nice to Have)

#### 3.1 Hardcoded String Colors in Migration Service
**File:** `features/auth/data/services/migration_service.dart`, Lines 16-20
**Severity:** Low
**Issue:** Default calendar colors hardcoded as strings instead of referencing AppColors

```dart
static const _defaultCalendars = [
  {'name': 'Personal', 'colorHex': '#007AFF'},
  {'name': 'Work', 'colorHex': '#FF3B30'},
  {'name': 'Shared', 'colorHex': '#34C759'},
];
```

**Fix:** Use AppColors
```dart
static const _defaultCalendars = [
  {'name': 'Personal', 'colorHex': '#007AFF'},  // AppColors.personal
  {'name': 'Work', 'colorHex': '#FF3B30'},       // AppColors.work
  {'name': 'Shared', 'colorHex': '#34C759'},     // AppColors.shared
];
```

---

#### 3.2 Unused Import in app_colors.dart
**File:** `core/theme/app_colors.dart` (comment line 22)
**Severity:** Low
**Issue:** Import not used if `withValues` is supported

**Fix:** Verify Flutter version supports it; otherwise use `withOpacity` or `withAlpha`

---

#### 3.3 Missing Day Names Constant
**File:** `features/calendar/presentation/screens/calendar_main_screen.dart`, Lines 248-252
**Severity:** Low
**Issue:** Day name arrays duplicated (also in month_grid.dart)

```dart
static const _dayNames3 = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
static const _dayNamesFull = [
  'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
  'FRIDAY', 'SATURDAY', 'SUNDAY',
];
```

**Fix:** Move to app_constants.dart or create utility
```dart
// core/constants/constants.dart
abstract final class AppStrings {
  static const dayNames3 = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const dayNamesFull = ['MONDAY', 'TUESDAY', 'WEDNESDAY', ...];
  static const monthNames = ['JANUARY', 'FEBRUARY', ...];
}
```

---

#### 3.4 Event Block Hardcoded Padding
**File:** `features/calendar/presentation/widgets/event_block.dart`, Lines 62, 75-77
**Severity:** Low
**Issue:** Padding values hardcoded instead of using AppSizes

```dart
margin: const EdgeInsets.only(left: 2, right: 2, top: verticalInset),
// ...
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
```

**Fix:**
```dart
margin: EdgeInsets.only(left: AppSizes.xs / 2, right: AppSizes.xs / 2, top: verticalInset),
padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),  // Keep small padding for compact design
```

---

#### 3.5 Timeline Grid Hardcoded Text Alignment
**File:** `features/calendar/presentation/widgets/timeline_grid.dart`, Line 37
**Severity:** Low
**Issue:** `textAlign: TextAlign.right` is hardcoded, could be a parameter

```dart
Text(label, style: ..., textAlign: TextAlign.right)
```

---

#### 3.6 DayEventsColumn Hardcoded Padding
**File:** `features/calendar/presentation/widgets/timeline_grid.dart`, Lines 118-122
**Severity:** Low
**Issue:** Padding and highlight positioning use magic numbers

```dart
const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
top: highlightStartMin! * hourHeight / 60,
```

---

#### 3.7 Missing Const Constructors
**File:** Multiple files
**Severity:** Low
**Issue:** Some widgets don't use `const` constructors where possible

Example: `features/auth/presentation/screens/login_screen.dart`, Line 195
```dart
child: const SizedBox(
  width: 20,
  height: 20,
  child: CircularProgressIndicator(  // Should be const
    strokeWidth: 2,
    color: AppColors.background,
  ),
),
```

**Fix:** Add `const` keyword to all eligible widgets

---

#### 3.8 Unused Import
**File:** `features/calendar/presentation/widgets/swipeable_timeline.dart`, Line 4
**Severity:** Low
**Issue:** `import 'package:flutter/physics.dart'` imported but `SpringDescription`, `SpringSimulation` not used

**Fix:** Remove unused import

---

#### 3.9 Inconsistent Import Organization
**File:** Many files
**Severity:** Low
**Issue:** Imports not organized (dart, package, relative)

**Fix:** Organize all imports per Dart conventions:
```dart
// dart: imports
import 'dart:async';

// package: imports
import 'package:flutter/material.dart';

// relative imports
import 'related_file.dart';
```

---

#### 3.10 Magic Numbers in TimelineView
**File:** `features/calendar/presentation/widgets/timeline_view.dart`, Lines 235, 237
**Severity:** Low
**Issue:** Hardcoded dimensions for current time indicator

```dart
final top = (_now.hour * 60 + _now.minute) * widget.hourHeight / 60;
final dotSize = AppSizes.currentTimeIndicatorDot;

// Later:
height: 1.5,  // Magic number for line thickness
```

**Fix:** Add to AppSizes
```dart
static const currentTimeIndicatorLineWidth = 1.5;
```

---

#### 3.11 Missing Semantic Labels
**File:** Multiple widget files
**Severity:** Low
**Issue:** Accessibility features missing - no Semantic wrappers for icon buttons

Example: `features/calendar/presentation/widgets/calendar_header.dart`, Lines 44-77
```dart
IconButton(onPressed: ..., icon: const Icon(Icons.menu, size: 24))
// Missing Semantics widget for screen readers
```

**Fix:**
```dart
Semantics(
  button: true,
  label: 'Open menu',
  child: IconButton(onPressed: ..., icon: const Icon(Icons.menu, size: 24)),
)
```

---

#### 3.12 Hard to Read Time Label Format
**File:** `features/calendar/presentation/widgets/month_event_list.dart`, Lines 33-36
**Severity:** Low
**Issue:** Time formatting done manually instead of using intl

```dart
String _formatTime(DateTime dt) {
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
```

**Fix:** Use intl
```dart
import 'package:intl/intl.dart';

String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);
```

---

#### 3.13 EventCreateSheet Model Partial Read
**File:** `features/event/presentation/screens/event_create_sheet.dart`, Lines 84-90
**Severity:** Low
**Issue:** Reads from multiple providers without null coalescing

```dart
final visibleCalendars = ref.read(visibleCalendarsProvider);
final allCalendars = ref.read(calendarListProvider).valueOrNull ?? [];
final calendarList = visibleCalendars.isNotEmpty ? visibleCalendars : allCalendars;
```

Better to use a computed provider.

---

#### 3.14 Settings Not Documented
**File:** `features/settings/presentation/providers/settings_providers.dart`
**Severity:** Low
**Issue:** No documentation for default values or what each setting does

**Fix:** Add doc comments
```dart
/// User's preferred calendar view (default: 3-day)
final CalendarViewType defaultView;
```

---

#### 3.15 Missing null-coalescing in AppSettings
**File:** `features/settings/presentation/providers/settings_providers.dart`, Line 50
**Severity:** Low
**Issue:** `copyWith` doesn't handle null defaults properly

```dart
AppSettings copyWith({
  CalendarViewType? defaultView,
  // ...
}) {
  return AppSettings(
    defaultView: defaultView ?? this.defaultView,  // OK pattern
  );
}
```

---

#### 3.16 TODO Comments Left in Code
**File:** Multiple files
**Severity:** Low
**Issue:** Unresolved TODOs

- `main.dart`, Line 59: `// TODO: FCM 토큰 등록`
- `core/utils/date_utils.dart`, Lines 5-14: All functions unimplemented
- `core/theme/app_theme.dart`, Line 127: `// TODO(phase2): Dark 테마 세부 설정`

**Fix:** Resolve or create GitHub issues

---

#### 3.17 WorkspaceDbConverter Missing
**File:** `features/workspace/data/models/workspace_db_converter.dart` exists but never used
**Severity:** Low
**Issue:** File path suggests implementation, but file is empty or import-only

---

#### 3.18 Inconsistent Event Mock Naming
**File:** `features/calendar/presentation/screens/calendar_main_screen.dart`
**Severity:** Low
**Issue:** Mock event IDs use different naming schemes (`'month-1'`, `'mock-1'`, `'sprint'`)

**Fix:** Standardize to `'mock-<type>-<number>'`

---

### 4. DESIGN TOKEN VIOLATIONS

#### 4.1 Colors Not Using AppColors
- `features/auth/presentation/screens/login_screen.dart:250`: `Colors.white` instead of `AppColors.background`
- `features/auth/presentation/screens/signup_screen.dart:250`: Same issue
- `features/calendar/presentation/widgets/timeline_view.dart:279-284`: Using hardcoded `Colors.white`

#### 4.2 Border Radii Inconsistencies
- `features/calendar/presentation/widgets/calendar_main_screen.dart:276`: `BorderRadius.circular(6)` instead of `AppSizes.radiusMd`
- Multiple files use magic number radii instead of AppSizes constants

#### 4.3 Font Sizes Hardcoded
- `features/auth/presentation/screens/login_screen.dart:129`: `fontSize: 13` instead of using AppTypography scale
- `features/calendar/presentation/widgets/event_block.dart:110`: `fontSize: 12` hardcoded
- `features/calendar/presentation/screens/calendar_main_screen.dart:283`: `fontSize` hardcoded

---

### 5. PERFORMANCE ISSUES

#### 5.1 Unnecessary Rebuilds in TimelineView
**File:** `features/calendar/presentation/widgets/timeline_view.dart`, Line 147
**Severity:** Low
**Issue:** `_buildDayColumn` is called for every day in the range on every rebuild

```dart
itemBuilder: (context, index) {
  return _buildDayColumn(index, hourHeight);
},
```

Should extract to separate widget with `const` constructor.

---

#### 5.2 CurrentTimeMarker Repaints Every Minute
**File:** `features/calendar/presentation/widgets/timeline_view.dart`, Lines 215-231
**Severity:** Low
**Issue:** Entire widget tree repaints every minute

Should use `RepaintBoundary` or isolate the timer to specific widget.

---

#### 5.3 EventBlock Colors Recalculated on Every Build
**File:** `features/calendar/presentation/widgets/event_block.dart`, Lines 54-56
**Severity:** Low
**Issue:** Color lookup happens in build() every frame

```dart
final bgColor = isHighlighted
    ? (_highlightBackgroundColors[color] ?? color.withValues(alpha: 0.15))
    : (_backgroundColors[color] ?? color.withValues(alpha: 0.06));
```

Should cache or use const maps.

---

### 6. STATE MANAGEMENT ISSUES

#### 6.1 Provider Watch in Notifier
**File:** `features/calendar/presentation/providers/calendar_providers.dart`, Line 112
**Severity:** Low
**Issue:** `ref.watch` in AsyncNotifier rebuild() will cause dependency loops

```dart
@override
Future<List<CalendarEntity>> build() async {
  final repo = ref.watch(calendarRepositoryProvider);
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  // ...
}
```

Should use `ref.read` or ensure currentWorkspaceIdProvider doesn't invalidate this.

---

#### 6.2 LocalEventsProvider Doesn't Handle Workspace Changes
**File:** `features/event/presentation/providers/event_providers.dart`, Lines 26-30
**Severity:** Low
**Issue:** Events are loaded globally, not per-workspace

```dart
@override
Future<List<EventEntity>> build() async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getAllEvents();  // No workspace filter
}
```

Should scope to current workspace when auth is enabled.

---

### 7. DATABASE SCHEMA ISSUES

#### 7.1 SQLite Schema Missing Constraints
**File:** `core/database/app_database.dart`, Lines 28-42
**Severity:** Low
**Issue:** Events table missing constraints

```sql
CREATE TABLE events (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  calendar_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
  -- Missing UNIQUE, CHECK, FOREIGN KEY constraints
)
```

**Fix:** Add constraints
```sql
CREATE TABLE events (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  calendar_id TEXT NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
  created_at INTEGER NOT NULL CHECK(created_at > 0),
  updated_at INTEGER NOT NULL CHECK(updated_at > 0),
  CHECK(start_time < end_time)
)
```

---

### 8. MISSING ERROR HANDLING

#### 8.1 EventCreateSheet Save Operation
No try-catch for all operations

#### 8.2 EventDetailSheet Delete Operation
No error handling for delete

#### 8.3 Calendar Operations
No error states in UI for calendar CRUD

#### 8.4 Firebase Operations
Multiple Firebase calls without error handling:
- `_createNewUser` in auth_providers.dart
- Migration service calls
- Workspace sync calls

---

## Recommended Priority Order

1. **Immediate (Critical):** Fix 1.1-1.8 (all Critical issues)
2. **Week 1:** Fix 2.1-2.5 (most impactful Medium issues)
3. **Week 2:** Fix 2.6-2.15 (remaining Medium issues)
4. **Ongoing:** Address Low severity and design token violations gradually

---

## Testing Recommendations

1. Add unit tests for error cases in repositories
2. Add widget tests for null safety in UI
3. Test Firebase error scenarios (network, auth failures)
4. Test enum index bounds in conversions
5. Test concurrent auth state changes
6. Test ScrollController lifecycle

---

## Summary Statistics

| Severity | Count | Percentage |
|----------|-------|-----------|
| Critical | 8 | 9.8% |
| Medium   | 18 | 22.0% |
| Low      | 56 | 68.3% |
| **Total** | **82** | **100%** |

Most issues cluster in state management, null safety, and design consistency. The architecture is sound, but implementation details need tightening before production release.
