# Ratio Calendar — Flutter 프로젝트 구조

> 이 문서는 Claude Code가 코드를 작성할 때 참고하는 프로젝트 아키텍처 가이드입니다.

## 아키텍처 개요

**Clean Architecture + Feature-first** 구조를 사용합니다.

```
lib/
├── main.dart                          ← 앱 진입점
├── core/                              ← 앱 전역 설정
│   ├── constants/
│   │   ├── app_sizes.dart             ← 패딩, 마진, 사이즈 상수
│   │   ├── app_durations.dart         ← 애니메이션 duration 상수
│   │   └── enums.dart                 ← 공통 enum (ViewType, Recurrence, Alert 등)
│   ├── theme/
│   │   ├── app_colors.dart            ← 컬러 시스템 (#FFFFFF, #1A1A1A, #007AFF 등)
│   │   ├── app_typography.dart        ← 타이포그래피 (28px 월타이틀 ~ 11px 캡션)
│   │   └── app_theme.dart             ← Light/Dark ThemeData
│   ├── router/
│   │   └── app_router.dart            ← GoRouter 라우트 정의
│   └── utils/
│       └── date_utils.dart            ← 날짜/시간 헬퍼 함수
│
├── features/                          ← 기능별 모듈 (Feature-first)
│   ├── calendar/                      ← 캘린더 뷰 + 캘린더 관리
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── calendar_remote_datasource.dart  ← Firestore
│   │   │   │   └── calendar_local_datasource.dart   ← Isar 캐시
│   │   │   ├── models/                ← Firestore/Isar용 데이터 모델
│   │   │   └── repositories/          ← Repository 구현체
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── calendar_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── calendar_repository.dart  ← 추상 인터페이스
│   │   │   └── usecases/              ← 비즈니스 로직
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── calendar_main_screen.dart  ← 홈 화면 (3-Day 기본)
│   │       ├── widgets/
│   │       │   ├── timeline_view.dart           ← 24시간 타임라인
│   │       │   ├── event_block.dart             ← 이벤트 블록 카드
│   │       │   ├── current_time_indicator.dart  ← 빨간 점 + 수평선
│   │       │   ├── calendar_header.dart         ← 월/년도 헤더
│   │       │   ├── day_header_row.dart          ← 요일/날짜 행
│   │       │   ├── pinch_zoom_handler.dart      ← 핀치 줌 제스처 (hourHeight 동적 조절, 30~150px)
│   │       │   └── swipe_navigation.dart        ← 수평 스와이프 날짜 이동 (velocity 기반)
│   │       └── providers/
│   │           └── calendar_providers.dart       ← Riverpod 상태
│   │
│   ├── event/                         ← 일정(이벤트) CRUD
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── event_remote_datasource.dart
│   │   │   │   └── event_local_datasource.dart
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── event_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── event_repository.dart
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── event_create_sheet.dart  ← 일정 생성 Bottom Sheet
│   │       │   └── event_detail_sheet.dart  ← 일정 상세 Bottom Sheet
│   │       ├── widgets/
│   │       └── providers/
│   │           └── event_providers.dart
│   │
│   ├── side_menu/                     ← 사이드 메뉴 (Drawer)
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── side_menu_screen.dart
│   │       ├── widgets/
│   │       └── providers/
│   │
│   ├── auth/                          ← 인증 (Firebase Auth)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   │
│   └── settings/                      ← 설정 화면
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           └── providers/
│
└── shared/                            ← 여러 feature에서 공유하는 위젯/유틸
    ├── widgets/
    │   ├── ratio_bottom_sheet.dart     ← 공통 Bottom Sheet 래퍼
    │   └── attendee_avatar.dart       ← 참석자 이니셜 아바타
    ├── extensions/
    └── mixins/

test/                                  ← 테스트 (동일 구조 미러링)
├── core/
├── features/
│   ├── calendar/
│   ├── event/
│   └── auth/
└── helpers/

assets/
├── icons/                             ← SVG/PNG 아이콘
├── fonts/                             ← 커스텀 폰트 (SF Pro 등)
└── images/                            ← 앱 이미지
```

## 레이어 규칙

| 레이어 | 역할 | 의존 방향 |
|--------|------|-----------|
| **Presentation** | UI (Screen, Widget) + 상태 (Riverpod Provider) | → Domain |
| **Domain** | Entity, Repository 인터페이스, UseCase | 외부 의존 없음 |
| **Data** | DataSource (Firestore/Isar), Model, Repository 구현 | → Domain |

Presentation → Domain ← Data (의존성 역전)

## 주요 기술 스택

| 역할 | 패키지 |
|------|--------|
| 상태 관리 | flutter_riverpod + riverpod_generator |
| 라우팅 | go_router |
| 캘린더 | table_calendar |
| 애니메이션 | flutter_animate |
| 원격 DB | cloud_firestore |
| 로컬 DB | isar |
| 인증 | firebase_auth |
| 푸시 알림 | firebase_messaging + flutter_local_notifications |
| 코드 생성 | freezed, json_serializable, build_runner |
| 린트 | very_good_analysis |
| 테스트 | mocktail |

## Firestore 컬렉션 구조

```
users/{userId}
  - email, displayName, photoUrl, defaultWorkspaceId

workspaces/{workspaceId}
  - name, ownerId, members[], createdAt

workspaces/{workspaceId}/calendars/{calendarId}
  - name, colorHex, isVisible, createdAt

workspaces/{workspaceId}/calendars/{calendarId}/events/{eventId}
  - title, date, startTime, endTime
  - recurrence, alert, description, attendees[]
  - createdAt, updatedAt
```

## 코드 생성 명령어

```bash
# freezed, json_serializable, riverpod_generator 실행
dart run build_runner build --delete-conflicting-outputs

# 지속적 감시 모드
dart run build_runner watch --delete-conflicting-outputs
```

## 개발 순서 (Claude Code용 가이드)

1. **Entity + Enum** — freezed로 immutable 모델 정의
2. **Repository 인터페이스** — domain/repositories에 추상 클래스
3. **DataSource + Model** — Firestore/Isar 연동
4. **Repository 구현** — data/repositories에 인터페이스 구현
5. **Provider** — Riverpod으로 상태 관리 연결
6. **Screen + Widget** — Stitch 디자인을 Flutter 위젯으로 변환
7. **제스처 시스템** — 핀치 줌(타임라인 확대/축소) + 수평 스와이프(날짜 이동) 구현. 제스처 충돌 방지 필수.
8. **테스트** — feature별 unit + widget test
