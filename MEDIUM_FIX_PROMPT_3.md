# Medium Fix 3/5 — MonthGrid + Swipeable 버그

## 1. month_grid.dart — 다음 달 패딩 계산 수정
다음 달 날짜 채울 때 `DateTime(year, month+1, 1)` 기준으로 계산하도록 변경. 현재 방식은 day 파라미터가 실제 일수를 넘을 수 있음.

## 2. swipeable_timeline.dart — baseDate 갱신 안되는 문제
`_baseDate`가 최초 build에서만 설정됨. 월 변경 등 외부 네비게이션 시에도 업데이트 되도록 수정.

## 3. event_create_sheet.dart — 23시 이벤트 생성 버그
`nextHour`가 24 이상이면 다음 날 0시로 처리. 현재는 `.clamp(0, 23)`만 해서 23시에 고정됨.

수정 후 `flutter analyze` 확인.
