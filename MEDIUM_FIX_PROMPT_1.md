# Medium Fix 1/5 — Timer 안전 + 로딩 상태

## 1. timeline_view.dart — Timer 콜백 안전 체크
`Timer.periodic` 콜백 안에 `if (mounted)` 체크를 추가해줘. 위젯이 dispose된 후 setState가 호출되면 에러남.

## 2. calendar_main_screen.dart — 로딩/에러 상태 추가
`calendarListProvider`와 `localEventsByDateProvider`에 AsyncValue의 loading, error 상태를 처리해줘. 로딩 중 CircularProgressIndicator, 에러 시 SnackBar.

## 3. event_block.dart — 높이 음수 방지
이벤트 높이 계산에서 `.clamp(0, double.infinity)` 추가. 4분 미만 이벤트가 음수 높이가 되는 버그.

수정 후 `flutter analyze` 확인.
