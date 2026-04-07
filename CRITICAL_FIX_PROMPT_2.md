# Critical Bug Fix Prompt 2/2 — Controller Lifecycle, Error Handling, Bounds Check

아래 4개의 Critical 버그를 수정해줘.

---

## 5. swipeable_timeline.dart — ScrollController 메모리 릭
**파일:** `lib/features/calendar/presentation/widgets/swipeable_timeline.dart`
**문제:** `_hController`와 `_headerController`가 build()에서 재생성될 때 이전 controller가 dispose되지 않음.

**수정:** controller 생성 전에 이전 것을 정리하고, `_initialized` 플래그로 한 번만 생성되도록:
```dart
if (!_initialized) {
  _hController?.removeListener(_syncHeader);
  _hController?.dispose();
  _headerController?.dispose();

  _hController = ScrollController(initialScrollOffset: initialOffset);
  _headerController = ScrollController(initialScrollOffset: initialOffset);
  _hController!.addListener(_syncHeader);
  _initialized = true;
}
```
`dispose()` 메서드에서도 두 controller 모두 정리되는지 확인해줘.

---

## 6. event_create_sheet.dart — Save 에러 핸들링 누락
**파일:** `lib/features/event/presentation/screens/event_create_sheet.dart`
**문제:** `_save()` 메서드에 try-catch가 없어서 repository 에러 시 sheet가 크래시됨.

**수정:**
```dart
Future<void> _save() async {
  try {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    // ... 기존 save 로직 ...
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이벤트 저장 실패: $e')),
      );
    }
  }
}
```
같은 파일에 delete 로직이 있다면 거기에도 try-catch 추가.

---

## 7. month_grid.dart — Index Out of Bounds
**파일:** `lib/features/calendar/presentation/widgets/month_grid.dart`
**문제:** `startOfWeekDay`가 1-7 범위 밖일 때 `_allDayLabels.sublist()` 에러.

**수정:** 입력값 검증 추가:
```dart
final validStartDay = startOfWeekDay.clamp(1, 7);
final startIndex = (validStartDay - 1) % 7;
return [
  ..._allDayLabels.sublist(startIndex),
  ..._allDayLabels.sublist(0, startIndex),
];
```

다음 달 패딩 계산도 수정 (Line 94 부근):
```dart
final nextMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 1);
while (dates.length < 42) {
  final nextDayNum = dates.length - startWeekday - daysInMonth + 1;
  dates.add(DateTime(nextMonth.year, nextMonth.month, nextDayNum));
}
```

---

## 8. workspace_providers.dart — Race Condition
**파일:** `lib/features/workspace/presentation/providers/workspace_providers.dart`
**문제:** `syncWorkspacesFromFirestore(user.id)` await 중에 auth 상태가 변경될 수 있음.

**수정:**
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
      // 네트워크 에러 시 로컬 데이터로 fallback
      debugPrint('Workspace sync failed: $e');
    }
  }

  await repo.ensureDefaultWorkspace();
  return repo.getAllWorkspaces();
}
```

---

수정 후 `flutter analyze`로 에러가 없는지 확인해줘.
