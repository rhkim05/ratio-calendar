# Medium Fix 2/5 — Platform + Validation

## 1. app_theme.dart — Platform override 제거
`platform: TargetPlatform.android` 줄을 삭제해. Flutter가 자동으로 플랫폼을 감지하게.

## 2. login_screen.dart + signup_screen.dart — 이메일 검증 강화
`!v.contains('@')` 대신 RegExp로 기본 이메일 형식 체크:
`RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)`

## 3. settings_providers.dart — Enum 역직렬화 안전 처리
SharedPreferences에서 enum index 읽을 때 bounds 체크 메서드 사용. 유효하지 않은 index면 기본값 반환.

## 4. attendee_avatar.dart — initials 빈 문자열 체크
`parts[0][0]` 호출 전에 `parts[0].isNotEmpty` 체크 추가.

수정 후 `flutter analyze` 확인.
