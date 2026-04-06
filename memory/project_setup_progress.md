---
name: project_setup_progress
description: Ratio Calendar Flutter 프로젝트 Phase A 초기 설정 진행 상황
type: project
---

Ratio Calendar Flutter 앱의 Phase A 기초 설정이 완료됨.

**완료 항목:**
1. **프로젝트 구조** — STRUCTURE.md 기반 Clean Architecture + Feature-first 디렉토리 전체 생성 완료. 잘못 생성된 `{presentation` 디렉토리 정리함.
2. **의존성 설치** — `flutter pub get` 완료 (Flutter 경로: `/Users/dev/Code/flutter/bin/flutter`)
3. **Firebase 초기화** — `main.dart`에서 `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` 호출. `firebase_options.dart`는 FlutterFire CLI로 이미 생성되어 있었음.
4. **Freezed 엔티티** — `CalendarEntity`, `EventEntity` freezed + json_serializable로 생성. Firestore 컬렉션 구조 기반 필드 매핑.
5. **Riverpod Provider** — calendar/event providers 기본 구조 완성. `@riverpod` 어노테이션 + build_runner 코드 생성.
6. **GoRouter 라우팅** — `MaterialApp.router` 전환, `/` (캘린더 메인), `/menu` (사이드 메뉴), `/settings` (설정, 슬라이드 전환) 라우트 설정.

**Why:** 이후 대화에서 이미 완료된 작업을 반복하지 않고, 다음 단계(UI 구현, Repository 연결 등)로 바로 진행하기 위함.
**How to apply:** 새 작업 요청 시 위 항목은 이미 완료된 것으로 간주. Data 레이어(Repository 구현, Firestore 연동)와 UI 위젯 구현이 다음 단계.
