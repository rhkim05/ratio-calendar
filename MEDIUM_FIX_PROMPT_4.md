# Medium Fix 4/5 — 디자인 토큰 통일

## 1. 하드코딩된 Colors 제거
아래 파일들에서 `Colors.white`를 `AppColors.background`로 교체:
- `login_screen.dart`
- `signup_screen.dart`
- `timeline_view.dart`

## 2. 하드코딩된 BorderRadius 제거
`calendar_main_screen.dart`에서 `BorderRadius.circular(6)` → `BorderRadius.circular(AppSizes.eventBorderRadius)` 로 교체. 다른 파일도 매직 넘버 radius가 있으면 AppSizes 상수로 교체.

## 3. 하드코딩된 fontSize 제거
- `login_screen.dart`: `fontSize: 13` → AppTypography 사용
- `event_block.dart`: `fontSize: 12` → AppTypography 사용
- `calendar_main_screen.dart`: 하드코딩된 fontSize → AppTypography 사용

수정 후 `flutter analyze` 확인.
