# Critical Bug Fix Prompt 1/2 — Null Safety & Memory Leaks

아래 4개의 Critical 버그를 수정해줘. 각 파일의 해당 위치를 찾아서 정확히 수정해.

---

## 1. migration_service.dart — Null Safety
**파일:** `lib/features/auth/data/services/migration_service.dart`
**문제:** `_loadUserEntity`에서 `data['defaultWorkspaceId']`를 null 체크 없이 `as String`으로 캐스팅. Firestore에 해당 키가 없으면 크래시.

**수정:**
```dart
defaultWorkspaceId: (data['defaultWorkspaceId'] as String?) ?? 'default-workspace-id',
```
같은 메서드 내 다른 Firestore 필드들도 모두 null-safe 캐스팅으로 변경해줘 (`as String?` + `?? default`).

---

## 2. event_isar_model.dart — Enum Index Bounds
**파일:** `lib/features/event/data/models/event_isar_model.dart`
**문제:** `RecurrenceType.values[map['recurrence'] as int]`와 `AlertType.values[map['alert'] as int]`가 유효하지 않은 인덱스일 때 `RangeError` 크래시.

**수정:** safe parsing 메서드를 추가해:
```dart
static RecurrenceType _safeRecurrence(int? index) {
  if (index == null || index < 0 || index >= RecurrenceType.values.length) {
    return RecurrenceType.never;
  }
  return RecurrenceType.values[index];
}

static AlertType _safeAlert(int? index) {
  if (index == null || index < 0 || index >= AlertType.values.length) {
    return AlertType.none;
  }
  return AlertType.values[index];
}
```
그리고 변환 코드에서 이 메서드를 사용하도록 교체.

---

## 3. auth_providers.dart — Stream Subscription 메모리 릭
**파일:** `lib/features/auth/presentation/providers/auth_providers.dart`
**문제:** `build()`가 rebuild될 때마다 `_authSub`에 새 listener가 생성되는데, 이전 subscription이 cancel되지 않음.

**수정:** `_authSub ??=`로 변경해서 이미 subscription이 있으면 새로 생성하지 않도록:
```dart
@override
AuthState build() {
  _datasource = ref.read(authRemoteDatasourceProvider);
  _migrationService = ref.read(migrationServiceProvider);
  _authSub ??= _datasource.authStateChanges.listen(_onAuthStateChanged);
  ref.onDispose(() {
    _authSub?.cancel();
    _authSub = null;
  });
  // ...
}
```

---

## 4. auth_providers.dart — Firestore Doc Force Unwrap
**파일:** `lib/features/auth/presentation/providers/auth_providers.dart` (같은 파일)
**문제:** `doc.data()!`가 force-unwrap됨. Firestore doc 구조가 변경되면 크래시.

**수정:**
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
      state = AuthError(message: 'Failed to load user data: $e');
    }
  }
}
```

---

수정 후 `flutter analyze`로 에러가 없는지 확인해줘.
