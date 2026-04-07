# Medium Fix 5/5 — State Management + 기타

## 1. calendar_providers.dart — ensureDefaults 중복 호출 방지
`calendarListProvider`의 `build()`에서 매번 `ensureDefaults`를 호출하고 있음. idempotent하게 처리하거나 한번만 호출되도록.

## 2. app_theme.dart — Dark 테마 비활성화
dark theme이 미완성임. `themeMode: ThemeMode.light`로 고정해서 사용자가 다크모드로 전환되지 않도록.

## 3. calendar_main_screen.dart — Mock 색상을 AppColors로 이동
`_mockColors` 맵을 `app_colors.dart`의 static const로 이동.

## 4. firebase_options.dart — 런타임 체크 추가
`main.dart`에서 Firebase 초기화 실패 시 try-catch로 감싸고 에러 로그 추가.

수정 후 `flutter analyze` 확인.
