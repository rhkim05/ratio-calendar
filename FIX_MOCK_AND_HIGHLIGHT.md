# 수정 2건: Mock 이벤트 삭제 + 이벤트 깜빡임 버그

---

## 1. Mock/기본 이벤트 전부 삭제

앱에 하드코딩된 기본 이벤트(mock events)를 모두 제거해줘.
- `calendar_main_screen.dart`에 있는 mock 이벤트 리스트 삭제
- 다른 파일에도 테스트용/샘플 이벤트가 하드코딩되어 있으면 전부 삭제
- 앱 시작 시 빈 캘린더 상태로 시작되게

---

## 2. 캘린더 빈 곳 탭할 때 이벤트들이 파란색으로 깜빡거리는 버그

**원인:** `timeline_gesture_handler.dart`의 `handleTapAt()`에서 `setState()` 안에 `highlightedEventId = null`을 넣으면, 전체 TimelineView가 rebuild되면서 EventBlock의 `AnimatedContainer`가 200ms 애니메이션을 실행함.

**수정:** `handleTapAt()`에서 `highlightedEventId = null`을 `setState()` 바깥으로 빼서, setState 전에 직접 할당해. 이렇게 하면 setState로 rebuild될 때 이미 null이라 EventBlock이 변화를 감지하지 않음.

```dart
// handleTapAt() 내부 - else 분기
final hour = (rawMinute / 60).floor().clamp(0, 23);

// setState 밖에서 먼저 클리어
highlightedEventId = null;

setState(() {
  highlightedDate = date;
  highlightStartMin = hour * 60;
  highlightEndMin = min((hour + 1) * 60, 24 * 60);
  // highlightedEventId = null 은 여기서 제거
});
```

`_onEventTapWithScroll()` 함수에서도 마찬가지로, sheet가 닫힌 후 `highlightedEventId = null`을 setState 밖에서 처리하는지 확인해줘.

---

수정 후 `flutter analyze` 확인.
