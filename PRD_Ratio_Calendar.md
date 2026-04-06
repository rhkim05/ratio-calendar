# Ratio Calendar — Product Requirements Document

**Version**: 2.0
**Date**: 2026-04-02
**Author**: Drafty Admin
**Status**: Draft
**Platform**: iOS / Android (Flutter)
**Design Tool**: Google Stitch
**Dev Agent**: Claude Code (AI)

> *"Less, but better."* — Dieter Rams

---

## 목차

1. Executive Summary
2. 문제 정의 & 솔루션
3. 타겟 사용자
4. 디자인 철학 & UI/UX
5. 기능 요구사항 (Phase 1–3)
6. 기술 스택 — 벤치마크 비교
7. 개발 워크플로우 (Stitch + Claude Code)
8. 아키텍처 & 주요 패키지
9. 비기능 요구사항
10. 비즈니스 모델
11. 로드맵
12. 성공 지표 (KPIs)
13. 리스크 & 대응
14. 경쟁 분석

---

## 1. Executive Summary

Ratio Calendar는 **미니멀리즘을 핵심 철학**으로 하는 iOS/Android 모바일 캘린더 앱이다. 기존 캘린더 앱들이 기능 과잉으로 복잡해진 반면, Ratio Calendar는 "적절한 비율(Ratio)"의 정보만 보여줌으로써 사용자가 일정에 집중할 수 있도록 돕는다.

디자인은 **Google Stitch**로 제작하고, 개발은 **Claude Code**(AI 코딩 에이전트)에 전적으로 위임하는 에이전틱 개발 방식을 채택한다. Product Owner가 모든 화면을 검토하며, 직접 코딩은 하지 않는다. **Flutter** 프레임워크를 사용하여 단일 코드베이스로 양 플랫폼을 동시 개발한다.

| Target | Stack | MVP 기간 | 예상 비용 |
|--------|-------|---------|----------|
| iOS + Android | Flutter (Dart) | 12주 | $40K – $60K |

---

## 2. 문제 정의 & 솔루션

### 2.1 문제

- **정보 과부하** — Google Calendar, Outlook 등은 한 화면에 과도한 정보를 표시하여 핵심 일정 파악이 어렵다.
- **복잡한 UI** — 수많은 메뉴, 설정, 토글이 사용자 경험을 해친다.
- **시각적 피로** — 다양한 색상, 아이콘, 뱃지가 혼합되어 시각적 노이즈가 크다.
- **느린 일정 등록** — 불필요한 필드와 단계가 일정 추가 속도를 저하시킨다.

### 2.2 솔루션 — 3가지 핵심 원칙

- **Minimal Interface** — 화면에 필수 정보만 표시하고, 나머지는 필요 시에만 노출
- **Quick Capture** — 최소 2탭으로 일정 생성 완료
- **Visual Calm** — 절제된 색상 팔레트와 여백 중심 레이아웃

---

## 3. 타겟 사용자

### 3.1 1차 타겟: 직장인 (25–40세)

회의, 딥워크, 스프린트 등 업무 일정 관리가 핵심이다. 워크스페이스(팀) 캘린더와 개인 캘린더를 병행하며, 빠른 일정 확인과 등록이 중요하다.

### 3.2 2차 타겟: 대학생 및 취준생 (18–28세)

수업, 스터디, 과제 마감일을 관리한다. 심플한 앱을 선호하는 세대이며, 무료 또는 저가 요금제에 민감하다.

---

## 4. 디자인 철학 & UI/UX

모든 UI/UX 디자인은 **Google Stitch**로 제작되어 있으며, 레퍼런스 스크린샷이 각 화면의 비주얼 언어를 정의한다.

### 4.1 디자인 원칙

| 원칙 | 설명 | 적용 방식 |
|------|------|-----------|
| 여백 우선 | 콘텐츠보다 여백이 주인공 | 이벤트 블록 간 충분한 간격, 시간 라벨 좌측 배치 |
| 절제된 색상 | 최소한의 컬러 팔레트 | 캘린더별 1색상, 배경은 순백(#FFFFFF) |
| 타이포그래피 위계 | 크기와 굵기로 정보 구조화 | 월 15px > 날짜 33px > 이벤트 14px > 시간 11px (날짜가 가장 큰 시각적 앵커) |
| 부드러운 전환 | 모든 변화에 애니메이션 적용 | Fade+slide 뷰 전환, Bottom Sheet 이벤트 |

### 4.2 컬러 시스템

| 역할 | Hex Value | 용도 |
|------|-----------|------|
| Background | #FFFFFF | 메인 배경 — surface_container_lowest |
| Surface | #F2F4F4 | 카드, 네비게이션 — surface_container_low |
| Surface Highest | #DDE4E5 | 콜아웃, 유틸리티 패널 |
| Text Primary | #1A1A1A | 제목, 본문 — Ink |
| Text Secondary | #8E8E93 | 라벨, 시간 — System Gray |
| Today Highlight | #003049 | 오늘 날짜 강조 — 둥근 정사각형(borderRadius 6) 배경 |
| Personal Calendar | #007AFF | Blue 액센트 |
| Work Calendar | #FF3B30 | Red 액센트 |
| Shared Calendar | #34C759 | Green 액센트 |
| Grid Line | #ACB3B4 at 15% opacity | Ghost border — 거의 투명한 구분선 |
| FAB | #1A1A1A | 다크 모노크롬 둥근 사각형(borderRadius 16) |
| Sprint Planning | 보더 #2563EB / 배경 #EFF6FF | Blue 계열 |
| Design Sync | 보더 #0D9488 / 배경 #F0FDFA | Teal 계열 |
| Deep Work | 보더 #D97706 / 배경 #FFFBEB | Amber 계열 |
| Team Standup | 보더 #EA580C / 배경 #FFF7ED | Orange 계열 |

### 4.3 타이포그래피

폰트: **Inter** (Google Fonts) — 모든 텍스트에 통일 적용

```
월 타이틀:      Inter — ExtraBold(w800), 15px, letterSpacing 2.5, ALL-CAPS
날짜 숫자:      Inter — Bold(w700), 33px (헤더의 시각적 앵커, 가장 큰 요소)
요일 라벨:      Inter — Bold(w700), 11px, #8E8E93, letterSpacing 2.0, ALL-CAPS
이벤트 제목:    Inter — Medium(w500), 14px
이벤트 시간:    Inter — Regular(w400), 11px, #8E8E93
섹션 라벨:      Inter — Bold(w700), 10px, #8E8E93, letterSpacing 2.0, ALL-CAPS
Sheet 제목:     Inter — Black(w900), 24px, letterSpacing -0.03em
Headline:       Inter — Black(w900), 18px, letterSpacing -0.03em
Body:           Inter — Regular(w400), 14px
```

### 4.4 핵심 화면 구성 (Stitch 레퍼런스 기반)

**캘린더 메인 뷰 (3-Day 기본)** — 상단에 월/년도 헤더(15px, ALL-CAPS, wide tracking)를 표시하고, 그 아래 요일/날짜 행을 배치한다(날짜 숫자 33px이 시각적 앵커). 오늘 날짜는 #003049 둥근 정사각형(borderRadius 6) 배경으로 강조. 세로 스크롤 가능한 타임라인에 이벤트를 연한 파스텔 블록으로 표시하며, 좌측 4px 컬러 보더를 둔다. 이벤트 블록 border-radius는 6px (8px 초과 금지). 이벤트 블록에는 제목만 표시(시간 미표시). 그리드 라인은 #ACB3B4 at 15% opacity (Ghost border). 현재 시각은 빨간 점(●) + 수평선으로 표시. 우하단 다크 FAB(#1A1A1A, 둥근 사각형) 버튼으로 빠른 일정 추가.

**사이드 메뉴** — 좌측에서 슬라이드로 등장. 상단: 워크스페이스/프로필 정보. 중간: 뷰 전환 옵션(Day, 3-Day, Week, Month, Year). 하단: 캘린더 목록(색상 도트) + 설정 링크.

**일정 생성 (Bottom Sheet)** — FAB(+) 또는 빈 공간 탭 시 하단에서 올라오는 Bottom Sheet. 큰 제목 필드가 상단에 위치. 카드형 행으로 DATE / TIME / REPEAT / ALERT 배치. DESCRIPTION & NOTES 영역. 좌측 X(닫기), 우측 ✓(저장).

**일정 상세 보기 (Bottom Sheet)** — 이벤트 탭 시 올라오는 상세 화면. 동시에 뒤쪽 캘린더 타임라인이 해당 이벤트가 Sheet 위 보이는 영역(상단 30~40%)의 중앙에 오도록 부드럽게 자동 스크롤됨. 제목 + 캘린더 라벨, DATE / TIME / ALERT / PEOPLE 표시. 참석자는 이니셜 원형 아바타 + "+N" 오버플로우. 헤더에 편집/삭제 아이콘.

---

## 5. 기능 요구사항

### 5.1 Phase 1 — MVP

#### 캘린더 뷰

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| Day View | 단일 날짜의 시간대별 타임라인 | P0 |
| 3-Day View | 3일간 일정 나란히 표시 (기본 뷰) | P0 |
| Month View | 월별 그리드에 이벤트 도트/프리뷰 | P0 |
| Week View | 7일간 타임라인 | P2 (Phase 2) |
| Year View | 연간 미니맵 (월별 컴팩트) | P2 (Phase 2) |
| 현재 시각 인디케이터 | 빨간 점 + 수평선 | P0 |
| 뷰 전환 애니메이션 | Fade + slide 트랜지션 | P1 |
| 핀치 줌 (Pinch to Zoom) | 세로 방향 확대/축소 — 타임라인 시간 간격 조절 (축소: 하루 전체 한눈에, 확대: 30분 단위 세밀 보기). hourHeight를 동적으로 조절 (최소 30px ~ 최대 150px). Google Calendar과 동일한 UX. | P0 |
| 수평 스와이프 (Horizontal Swipe) | 좌우 스와이프로 날짜 이동. 살짝 스와이프 시 1일 이동, 크게 스와이프 시 스와이프 속도(velocity)에 비례하여 여러 일 이동. 3-Day View에서 MON/TUE/WED → TUE/WED/THU 또는 한번에 THU/FRI/SAT 등. Day View, 3-Day View 모두 적용. | P0 |

#### 일정 관리 (CRUD)

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| 일정 생성 | Bottom Sheet 빠른 추가 UI | P0 |
| 일정 조회 | 이벤트 탭 시 상세 Bottom Sheet + 캘린더 타임라인이 해당 이벤트가 Sheet 위 보이는 영역의 중앙에 오도록 자동 스크롤 (ScrollController.animateTo) | P0 |
| 일정 수정 | 상세 화면에서 편집 모드 진입 | P0 |
| 일정 삭제 | 확인 다이얼로그 후 삭제 | P0 |
| 드래그 앤 드롭 | 타임라인에서 드래그로 시간 변경 | P1 |
| 제스처 충돌 방지 | 핀치 줌(세로)과 수평 스와이프(가로)가 동시에 충돌하지 않도록 제스처 방향 감지 로직 적용 | P0 |
| 빈 공간 탭 생성 | 빈 타임라인 탭 시 1시간 단위로 스냅하여 생성. 첫 탭: 해당 1시간 블록 하이라이트(점선 테두리 + 연한 배경). 두 번째 탭: 이벤트 생성 Bottom Sheet 열림(시작/종료 시간 자동 입력). 다른 곳 탭 시 하이라이트 해제 후 새 위치 하이라이트. | P0 |

#### 일정 속성

| 속성 | 설명 | 필수 여부 |
|------|------|-----------|
| 제목 | 이벤트 이름 | 필수 |
| 날짜 | 시작 날짜 | 필수 |
| 시간 | 시작 — 종료 시간 | 필수 |
| 반복 | Never / Daily / Weekly / Monthly / Yearly / Custom | 선택 |
| 알림 | None / 5분 / 15분 / 30분 / 1시간 / 1일 전 | 선택 (기본: 15분) |
| 설명 & 노트 | 자유 텍스트 (링크, 메모) | 선택 |
| 참석자 | 이니셜 아바타, 이메일 초대 | 선택 |
| 캘린더 지정 | 소속 캘린더 선택 | 필수 (기본: Personal) |

#### 캘린더 & 워크스페이스 관리

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| 다중 캘린더 | Personal / Work / Shared 기본 제공 | P0 |
| 캘린더 추가/삭제 | 사용자 정의 캘린더 | P0 |
| 캘린더 색상 | 캘린더별 고유 색상 | P0 |
| 캘린더 토글 | 사이드 메뉴에서 표시/숨기기 | P0 |
| 워크스페이스 생성 | 팀/조직 단위 워크스페이스 | P0 |
| 워크스페이스 전환 | 사이드 메뉴 상단 드롭다운 | P0 |
| 멤버 초대 | 이메일 기반 팀원 초대 | P1 |
| 로컬 알림 | 설정된 시간에 푸시 알림 | P0 |

### 5.2 Phase 2 — 확장 기능

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| Google Calendar 동기화 | Google 계정 양방향 싱크 | P1 |
| Apple Calendar 동기화 | iCloud 캘린더 연동 | P1 |
| 홈 화면 위젯 | 오늘 일정 위젯 (iOS + Android) | P1 |
| 검색 | 이벤트 제목/내용 기반 검색 | P1 |
| 다크 모드 | 시스템 설정 연동 다크 테마 | P1 |
| 일정 초대 | 이메일/앱 내 초대 발송 | P2 |
| 파일 첨부 | 이벤트에 이미지/문서 첨부 | P2 |

### 5.3 Phase 3 — 프리미엄

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| AI 스마트 스케줄링 | 빈 시간 자동 추천, 충돌 감지 | P2 |
| 포커스 모드 | 딥워크 시간대 자동 보호 | P2 |
| 팀 가용성 뷰 | 팀원 일정 오버레이 표시 | P2 |
| 분석 대시보드 | 시간 사용 패턴 분석 | P3 |
| Outlook 동기화 | Microsoft 365 연동 | P2 |
| Slack/Teams 연동 | 상태 자동 업데이트 | P3 |

---

## 6. 기술 스택 — 벤치마크 비교

모든 벤치마크 데이터는 2025~2026년 독립적인 연구 및 설문에 기반한다.

### 6.1 앱 시작 시간 (Cold Start)

| 프레임워크 | Cold Start | 비고 |
|-----------|-----------|------|
| Native (Swift) | ~0.9초 | 첫 프레임 50ms 이내 |
| Native (Kotlin) | ~1.0초 | — |
| Flutter | ~1.2초 | Impeller 엔진 최적화 |
| React Native | 1.2~2.0초 | Hermes 엔진, 번들 크기 의존 |

> 출처: SynergyBoat 2025, Chandru/Medium 2025

### 6.2 프레임 레이트 (FPS)

| 시나리오 | Flutter | React Native | Native |
|---------|---------|--------------|--------|
| 일반 애니메이션 | 60~120 FPS | 55~60 FPS | 60 FPS |
| 복잡한 애니메이션 | 117.75 FPS | 45~50 FPS | 60 FPS |
| 1,000개 카드 리스트 | ~25ms/프레임 | 35~50ms/프레임 | <20ms/프레임 |
| 프레임 래스터화 (iOS) | 1.72ms | — | 간헐적 예산 초과 |

> 출처: Orient Software, ThoughtBot, SynergyBoat 2025

### 6.3 메모리 & 앱 크기

| 항목 | Flutter | React Native | Native |
|------|---------|--------------|--------|
| RAM (유휴) | ~110MB | — | ~100MB |
| RAM (활성/최대) | ~200 / 253MB | — / 139MB | ~100MB |
| APK (중간 복잡도) | 16.8MB | 21.9MB (+30%) | ~10MB |
| IPA (중간 복잡도) | 71.5MB | 112.3MB (+57%) | ~40MB |

> 출처: Tech Insider 2026, Orient Software

### 6.4 CPU & 배터리

| 항목 | Flutter | React Native | Native |
|------|---------|--------------|--------|
| CPU (애니메이션) | 5.4% | 11.7% | 기준선 |
| CPU (일반 사용) | 43.42% | 52.92% | 기준선 |
| 배터리 (mAh) | 65.28 (+31%) | 79.01 (+59%) | 49.7 (기준선) |

> 출처: Orient Software, inVerita

### 6.5 개발 효율성

| 항목 | Flutter | React Native | Native (iOS+Android) |
|------|---------|--------------|---------------------|
| 코드 재사용률 | 95%+ | 80~90% | 0% (별도 코드베이스) |
| MVP 기간 | 3~4개월 | 3~4개월 | 6~8개월 |
| Native 대비 시간 절감 | 35~60% | 30~50% | 기준선 (1x) |
| 개발 비용 (중간) | $30K~$80K | $30K~$80K | $80K~$160K |
| GitHub Stars (2025) | 170,000+ | 120,000+ | — |
| 크로스플랫폼 시장점유율 | 46% | 35% | — |
| 상위 500 미국 앱 채택 | 5.24% | 12.57% | ~82% |

> 출처: Koderspedia, Stack Overflow 2025 설문, Statista

### 6.6 Ratio Calendar 비용 추정

| 프레임워크 | MVP 비용 | MVP 기간 | 연간 유지보수 |
|-----------|---------|---------|-------------|
| Flutter (권장) | $40K~$60K | 12주 | $8K~$15K |
| React Native | $40K~$65K | 12~14주 | $10K~$18K |
| Native (Swift+Kotlin) | $80K~$120K | 20~24주 | $20K~$35K |

### 6.7 Ratio Calendar 가중 점수

| 기능 | Flutter | RN | Native | 가중치 |
|------|---------|-----|--------|--------|
| 3-Day 타임라인 스크롤 (60fps) | 5 | 4 | 5 | ×3 (핵심) |
| Bottom Sheet 애니메이션 | 5 | 4 | 5 | ×3 (핵심) |
| 양 플랫폼 디자인 일관성 | 5 | 3 | 3 | ×3 (핵심) |
| 개발 속도 (12주 MVP) | 5 | 4 | 2 | ×3 (핵심) |
| 뷰 전환 품질 | 5 | 3 | 5 | ×2 |
| 대량 이벤트 렌더링 | 5 | 3 | 5 | ×2 |
| 홈 화면 위젯 | 3 | 3 | 5 | ×2 |
| 비용 효율성 | 5 | 5 | 2 | ×2 |
| 푸시 알림 | 5 | 5 | 5 | ×1 |
| 오프라인 동기화 | 4 | 4 | 5 | ×1 |
| **합계 (110점 만점)** | **107** | **81** | **91** | |

**권장: Flutter** — Impeller 엔진으로 네이티브와 구별 불가능한 애니메이션(117.75 FPS), 95%+ 코드 재사용, Native 대비 50~60% 비용 절감. 자체 렌더링 엔진이 양 플랫폼에서 픽셀 단위로 동일한 커스텀 미니멀 디자인을 보장한다.

---

## 7. 개발 워크플로우 (Stitch + Claude Code)

Ratio Calendar는 **에이전틱 개발(Agentic Development)** 방식을 채택한다. 디자인은 Google Stitch로, 코딩은 전적으로 Claude Code(AI 에이전트)에 위임하며, Product Owner가 모든 화면을 검토한다. 직접 코딩은 하지 않는다.

### 7.1 워크플로우 개요

| 단계 | 도구 | 작업 | 산출물 |
|------|------|------|--------|
| 1. 디자인 | Google Stitch | 텍스트/이미지 프롬프트로 UI 디자인 | UI 스크린 + HTML/CSS |
| 2. 연결 | Stitch MCP | Stitch를 Claude Code에 연결 | AI가 디자인 데이터 접근 가능 |
| 3. 개발 | Claude Code | 디자인을 Flutter/Dart 코드로 변환 | Flutter 소스 코드 |
| 4. 검토 | 사용자 (본인) | 코드 검토, 수정 요청 | 승인된 코드 |
| 5. 빌드 | Flutter CLI | 컴파일 및 에뮬레이터 테스트 | iOS / Android 앱 |

### 7.2 Stitch MCP 도구

Google Stitch는 공식 MCP(Model Context Protocol) 서버를 제공한다. Claude Code에 연결하면 다음 도구를 사용할 수 있다:

- **get_screen_image** — Stitch 디자인 스크린샷을 base64 이미지로 가져온다.
- **get_screen_code** — Stitch 디자인의 HTML/CSS 코드를 가져온다.
- **build_site** — 전체 프로젝트 스크린을 라우트로 매핑하여 빌드한다.

Claude Code는 이 데이터를 분석하여 Flutter 위젯 트리로 변환한다. 레이아웃, 색상, 타이포그래피를 매핑하며, 초기 완성도 70~80%에서 시작하여 사용자 피드백으로 품질을 높인다.

### 7.3 권장 MCP 설정

| MCP Server | 용도 |
|------------|------|
| Stitch MCP | Stitch 디자인 접근 (이미지, 코드, 레이아웃 메타데이터) |
| Dart / Flutter MCP | flutter analyze, flutter run, 위젯 문서 |
| Firebase MCP | Auth, Firestore, FCM 설정 |

### 7.4 품질 보증 프로세스

Claude Code가 생성한 모든 화면은 머지 전 사용자 검토를 거친다. Flutter DevTools로 성능(FPS, 메모리, 빌드 시간)을 모니터링하고, Firebase Crashlytics로 배포 후 안정성을 추적한다. Product Owner가 모든 UI 결정에 대한 최종 승인 권한을 갖는다.

---

## 8. 아키텍처 & 주요 패키지

### 8.1 레이어 아키텍처

| 레이어 | 구성 요소 | 기술 |
|--------|----------|------|
| Presentation | Screens, Widgets, Animations | Flutter Widgets, flutter_animate |
| State Management | Calendar / Event / Auth 상태 | Riverpod |
| Domain | Models, Repositories, Use Cases | Dart |
| Data | 원격 DB, 로컬 캐시, 인증, 푸시 | Firestore, Isar, Firebase Auth, FCM |
| Platform | 홈 화면 위젯 | iOS: WidgetKit / Android: Jetpack Glance |

### 8.2 주요 패키지

| 영역 | 패키지 | 용도 |
|------|--------|------|
| 캘린더 | table_calendar | 캘린더 뷰 렌더링 |
| 상태 관리 | riverpod | 앱 전체 반응형 상태 |
| 애니메이션 | flutter_animate | UI 트랜지션, 마이크로 인터랙션 |
| 로컬 DB | isar | 오프라인 캐시, 빠른 로컬 조회 |
| 인증 | firebase_auth | 로그인 / 회원가입 |
| 원격 DB | cloud_firestore | 이벤트/캘린더 데이터 동기화 |
| 푸시 알림 | firebase_messaging + flutter_local_notifications | 리마인더 |
| 위젯 브릿지 | home_widget | 홈 화면 위젯 연동 |
| 라우팅 | go_router | 화면 내비게이션 |
| 테마 | flex_color_scheme | 라이트/다크 모드 |

---

## 9. 비기능 요구사항

### 9.1 성능 목표

| 지표 | 목표값 |
|------|--------|
| 앱 Cold Start | < 2초 |
| 뷰 전환 속도 | < 300ms |
| 이벤트 렌더링 (100개) | 60fps 유지 |
| 일정 생성 응답 | < 500ms |
| 오프라인→온라인 동기화 | < 5초 |

### 9.2 플랫폼 지원

| 플랫폼 | 최소 버전 |
|--------|-----------|
| iOS | 15.0+ |
| Android | API 26 (Android 8.0)+ |

### 9.3 보안

- Firebase Auth 기반 인증 (이메일, Google, Apple Sign-In)
- Firestore Security Rules로 데이터 접근 제어
- 로컬 데이터 암호화 (Isar 내장)
- HTTPS/TLS 필수

### 9.4 접근성

- VoiceOver (iOS) / TalkBack (Android)
- Dynamic Type / 시스템 폰트 크기 반영
- 최소 터치 영역 44×44pt
- 색상 대비 WCAG 2.1 AA

### 9.5 국제화

| Phase | 지원 언어 |
|-------|----------|
| MVP | 한국어, 영어 |
| Phase 2 | 일본어, 중국어 (간체) |

---

## 10. 비즈니스 모델 — Freemium

| 기능 | Free | Pro ($3.99/월) | Team ($5.99/인/월) |
|------|------|----------------|-------------------|
| 캘린더 수 | 3개 제한 | 무제한 | 무제한 |
| 모든 뷰 (Day~Year) | ✓ | ✓ | ✓ |
| 로컬 알림 | ✓ | ✓ | ✓ |
| 색상 팔레트 | 기본 | 커스텀 | 커스텀 |
| 캘린더 동기화 | — | Google/Apple/Outlook | Google/Apple/Outlook |
| 홈 화면 위젯 | — | ✓ | ✓ |
| 다크 모드 | — | ✓ | ✓ |
| 파일 첨부 | — | ✓ | ✓ |
| 워크스페이스 (최대 50명) | — | — | ✓ |
| 팀 가용성 뷰 | — | — | ✓ |
| AI 스마트 스케줄링 | — | — | ✓ |
| 관리자 콘솔 | — | — | ✓ |

---

## 11. 로드맵

### Phase 1: MVP — 12주

| 주차 | 작업 내용 |
|------|-----------|
| 1–2주 | 프로젝트 셋업, 디자인 시스템 토큰, 기본 아키텍처 |
| 3–5주 | Day / 3-Day / Week 뷰, 타임라인 렌더링 엔진 |
| 6–7주 | 일정 CRUD (Bottom Sheet UI), 캘린더 관리 |
| 8–9주 | 인증 시스템, Firestore 연동, 데이터 동기화 레이어 |
| 10주 | Month / Year 뷰, 사이드 메뉴, 워크스페이스 전환 |
| 11주 | 로컬 알림, 오프라인 지원 |
| 12주 | QA, 성능 최적화, 클로즈드 베타 |

### Phase 2: 확장 — 8주

| 주차 | 작업 내용 |
|------|-----------|
| 13–14주 | Google Calendar 양방향 동기화 |
| 15–16주 | Apple Calendar 동기화, 검색 기능 |
| 17–18주 | 홈 화면 위젯 (iOS WidgetKit + Android Glance) |
| 19–20주 | 다크 모드, Pro 플랜 인앱 결제 연동 |

### Phase 3: 프리미엄 — 8주

| 주차 | 작업 내용 |
|------|-----------|
| 21–23주 | AI 스마트 스케줄링, 포커스 모드 |
| 24–25주 | 팀 가용성 뷰, Team 플랜 결제 |
| 26–28주 | Outlook 동기화, Slack/Teams 연동, 분석 대시보드 |

---

## 12. 성공 지표 (KPIs)

### 12.1 출시 후 3개월

| 지표 | 목표 |
|------|------|
| DAU (일간 활성 사용자) | 10,000명 |
| Day-1 리텐션 | > 40% |
| Day-7 리텐션 | > 25% |
| Day-30 리텐션 | > 15% |
| App Store 평점 | > 4.5 |
| Crash-free 세션 비율 | > 99.5% |

### 12.2 출시 후 6개월

| 지표 | 목표 |
|------|------|
| MAU (월간 활성 사용자) | 50,000명 |
| Pro 전환율 | > 5% |
| NPS (순추천지수) | > 50 |

---

## 13. 리스크 & 대응

| 리스크 | 영향도 | 가능성 | 대응 방안 |
|--------|--------|--------|-----------|
| Google/Apple 캘린더 API 변경 | 높음 | 중간 | CalDAV 표준 프로토콜 병행 |
| Flutter 호환성 이슈 | 중간 | 낮음 | Stable 채널, 버전 고정 |
| 초기 사용자 확보 어려움 | 높음 | 높음 | Product Hunt 런칭, 인플루언서 리뷰, 학생 프로모 |
| 동기화 충돌 (멀티 디바이스) | 중간 | 중간 | Last-write-wins + 충돌 해결 UI |
| 홈 위젯 플랫폼 제약 | 낮음 | 높음 | 네이티브 코드 최소화, Phase 2로 분리 |
| AI 생성 코드 품질 편차 | 중간 | 중간 | 모든 화면 사용자 검토, 반복 개선 |

---

## 14. 경쟁 분석

| 앱 | 강점 | 약점 | Ratio Calendar 차별점 |
|----|------|------|----------------------|
| Google Calendar | 생태계 통합, 무료 | 복잡한 UI, 커스터마이징 한계 | 미니멀 UI가 핵심 차별점 |
| Apple Calendar | iOS 통합, 깔끔 | Android 미지원, 기능 부족 | 크로스플랫폼 + 워크스페이스 |
| Fantastical | 자연어 입력, 뛰어난 디자인 | 비쌈 ($6.99/월) | 합리적 가격 + 더 미니멀 |
| Calendly | 외부 스케줄링 링크 | 개인 캘린더로서 약함 | 개인+팀 통합 캘린더 |
| Notion Calendar | 생산성 도구 통합 | 모바일 경험 미흡 | 모바일 퍼스트 디자인 철학 |

---

*End of Document — Ratio Calendar PRD v2.0 | April 2026*
