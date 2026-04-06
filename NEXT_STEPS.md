# Ratio Calendar — 다음 단계 가이드

> 현재 완료: PRD(v2) + 기술 비교 문서 + Flutter 프로젝트 구조(뼈대)
> 이 문서는 코딩을 하지 않는 Product Owner 기준으로 작성되었습니다.

---

## 전체 흐름 요약

```
현재 위치
    ↓
[Phase A] 환경 세팅 ─────────── 1~2일
    ↓
[Phase B] Stitch 디자인 완성 ── 1~2주
    ↓
[Phase C] Claude Code로 개발 ── 10~12주 (MVP)
    ↓
[Phase D] 테스트 & 출시 ─────── 2~3주
```

---

## Phase A. 개발 환경 세팅 (1~2일)

코딩은 Claude Code가 하지만, 빌드하고 실행할 환경은 본인 컴퓨터에 필요합니다.

### A-1. Flutter SDK 설치

macOS 기준:
1. https://docs.flutter.dev/get-started/install/macos 접속
2. Flutter SDK 다운로드 & 압축 해제
3. 터미널에서 `flutter doctor` 실행 — 빨간색 항목이 없으면 OK

필요한 것:
- Xcode (iOS 빌드용) — App Store에서 설치
- Android Studio (Android 빌드용) — https://developer.android.com/studio
- VS Code 또는 Android Studio에서 Flutter/Dart 플러그인 설치

검증 명령어:
```bash
flutter doctor -v
```
모든 항목에 ✓ 체크가 나와야 합니다.

### A-2. Firebase 프로젝트 생성

1. https://console.firebase.google.com 접속
2. "프로젝트 추가" → 이름: `ratio-calendar`
3. 아래 서비스 활성화:
   - **Authentication** → 로그인 방법에서 "이메일/비밀번호" + "Google" 활성화
   - **Cloud Firestore** → 데이터베이스 만들기 → 테스트 모드로 시작
   - **Cloud Messaging** → 자동 활성화됨
   - **Crashlytics** → 활성화
4. Flutter 앱 등록:
   - iOS 앱 추가 → Bundle ID: `com.ratiocalendar.app` → `GoogleService-Info.plist` 다운로드
   - Android 앱 추가 → 패키지명: `com.ratiocalendar.app` → `google-services.json` 다운로드
5. FlutterFire CLI로 자동 설정:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=ratio-calendar
   ```

### A-3. Flutter 프로젝트 초기화

현재 만들어둔 뼈대를 실제 Flutter 프로젝트로 변환합니다.
```bash
# 프로젝트 생성 (이미 만든 폴더와 합치기)
flutter create --org com.ratiocalendar ratio_calendar

# 생성된 프로젝트에 우리의 pubspec.yaml, lib/ 구조를 덮어씌우기
# → Claude Code에게 이 작업을 맡기면 됩니다

# 의존성 설치
cd ratio_calendar
flutter pub get

# 코드 생성 (freezed, riverpod_generator 등)
dart run build_runner build --delete-conflicting-outputs
```

### A-4. Claude Code 설치 & MCP 연결

1. Claude Code 설치: https://docs.claude.com/en/docs/claude-code
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```
2. 프로젝트 폴더에서 Claude Code 실행:
   ```bash
   cd ratio_calendar
   claude
   ```
3. MCP 서버 연결 (Claude Code 안에서):
   ```
   /mcp add stitch -- npx @anthropic-ai/stitch-mcp
   ```
   → Stitch MCP를 통해 Claude Code가 Stitch 디자인에 직접 접근 가능

---

## Phase B. Stitch 디자인 완성 (1~2주)

Claude Code에 넘기기 전에, Stitch에서 모든 핵심 화면의 디자인을 완성합니다.

### B-1. 필수 화면 (MVP — 7개)

| # | 화면 | 설명 | 우선순위 |
|---|------|------|----------|
| 1 | 캘린더 메인 (3-Day) | 월 헤더 + 요일 행 + 타임라인 + 이벤트 블록 + FAB (기본 뷰) | P0 |
| 2 | 캘린더 메인 (Day) | 1일 타임라인 버전 | P0 |
| 3 | 캘린더 메인 (Month) | 월별 그리드 + 이벤트 도트 | P0 |
| 4 | 사이드 메뉴 | 워크스페이스 + 뷰 전환 + 캘린더 목록 | P0 |
| 5 | 일정 생성 (Bottom Sheet) | 제목, 날짜, 시간, 반복, 알림, 메모 | P0 |
| 6 | 일정 상세 (Bottom Sheet) | 이벤트 정보 + 편집/삭제 | P0 |
| 7 | 설정 | 알림, 기본 뷰, 계정 관리 | P0 |

> **참고**: Week View, Year View는 MVP 이후(Phase 2)로 연기됨.

### B-2. 추가 화면 (MVP 보조 — 5개)

| # | 화면 | 설명 |
|---|------|------|
| 8 | 로그인 | 이메일 + Google 소셜 로그인 |
| 9 | 회원가입 | 이메일 기반 가입 |
| 10 | 캘린더 추가/편집 | 이름, 색상 선택 |
| 11 | Week View | 7일 타임라인 (Phase 2) |
| 12 | Year View | 연간 미니맵 (Phase 2) |

### B-3. Stitch 디자인 팁

- 각 화면을 **별도 스크린**으로 만들어야 Claude Code가 MCP로 개별 접근 가능
- 화면 이름을 명확히: `calendar_3day`, `calendar_day`, `event_create`, `side_menu` 등
- 컬러는 PRD에 정의한 Hex 값 그대로 사용 (Stitch에서 직접 입력)
- 상태별 변형도 만들어두면 좋음:
  - 이벤트가 있는 날 vs 빈 날
  - 오늘 날짜 하이라이트 상태
  - Bottom Sheet 열린 상태 / 닫힌 상태

---

## Phase C. Claude Code로 개발 (10~12주)

디자인이 준비되면, Claude Code에게 단계별로 작업을 지시합니다.
**한 번에 모든 걸 시키지 말고, 화면 단위로 나누어 지시하세요.**

### C-1. 1주차 — 기초 설정 (Week 1)

Claude Code에게 보낼 프롬프트 예시:

```
프로젝트 폴더에 STRUCTURE.md를 읽고 이 구조를 따라줘.
pubspec.yaml 의존성을 설치하고, Firebase를 초기화해줘.
freezed로 CalendarEntity와 EventEntity를 만들어줘.
Riverpod provider 기본 구조를 잡아줘.
GoRouter로 라우팅을 설정해줘.
```

산출물: 앱이 빌드되고 빈 화면이 뜨는 상태

### C-2. 2~3주차 — 캘린더 메인 뷰 (Week 2-3)

```
Stitch에서 calendar_3day 화면을 가져와서 Flutter로 구현해줘.
타임라인은 세로 스크롤이 되어야 하고, 1시간 = 60px 높이야.
현재 시각은 빨간 점 + 수평선으로 표시해.
FAB(+) 버튼을 우하단에 배치해줘.
```

→ 결과 확인 → 피드백 ("이벤트 블록 색상이 좀 더 연해야 해", "간격을 늘려줘" 등)

```
캘린더 타임라인에 핀치 줌(Pinch to Zoom)을 구현해줘.
- GestureDetector의 onScaleUpdate를 사용
- 세로 방향 핀치로 타임라인 시간 간격(hourHeight)을 동적으로 조절
- 최소 30px ~ 최대 150px per hour 범위 제한
- 축소하면 하루 전체가 한 화면에 보이고, 확대하면 30분 단위까지 세밀하게
- Google Calendar 앱과 동일한 UX
```

```
캘린더에 수평 스와이프(Horizontal Swipe)를 구현해줘.
- 좌우 스와이프로 날짜 이동
- 살짝 스와이프 시 1일 이동, 크게 스와이프 시 속도(velocity)에 비례하여 여러 일 이동
- 3-Day View 예: MON 6/TUE 7/WED 8 → 살짝 스와이프 → TUE 7/WED 8/THU 9
- 크게 스와이프 → THU 9/FRI 10/SAT 11 등
- Day View, 3-Day View 모두 적용
- 핀치 줌(세로)과 충돌하지 않도록 제스처 방향 감지 로직 적용
```

```
Day View와 Month View도 같은 방식으로 만들어줘.
Month View는 월별 그리드에 이벤트가 있는 날에 색상 도트를 표시해.
뷰 전환 시 fade + slide 애니메이션을 넣어줘.
```

> **참고**: Week View는 Phase 2에서 추가 예정. MVP에서는 3-Day + Day + Month 뷰를 구현.

### C-3. 4주차 — 사이드 메뉴 (Week 4)

```
Stitch에서 side_menu 화면을 가져와서 구현해줘.
좌측에서 슬라이드로 나타나야 해.
뷰 전환 버튼 (Day, 3-Day, Week, Month)을 넣고,
캘린더 목록에 색상 도트 + 토글을 넣어줘.
```

### C-4. 5~6주차 — 일정 CRUD (Week 5-6)

```
Stitch에서 event_create 화면을 가져와서 Bottom Sheet로 구현해줘.
FAB 버튼 누르면 아래에서 올라와야 해.
제목, 날짜, 시간, 반복, 알림, 메모 필드를 넣어줘.
저장하면 Firestore에 저장하고 캘린더에 바로 반영되게 해줘.
```

```
일정 상세 Bottom Sheet도 구현해줘.
이벤트 탭하면 상세 정보가 보이고, 편집/삭제 버튼이 있어야 해.
```

### C-5. 7~8주차 — 인증 + 워크스페이스 (Week 7-8)

```
Firebase Auth로 이메일 로그인/회원가입을 구현해줘.
Google 소셜 로그인도 추가해줘.
로그인하면 기본 워크스페이스와 Personal 캘린더가 자동 생성되게 해줘.
```

### C-6. 9~10주차 — 알림 + 폴리싱 (Week 9-10)

```
flutter_local_notifications로 일정 알림을 구현해줘.
앱 전체 UI를 Stitch 디자인과 비교하며 세부 조정해줘.
```

> **참고**: Month View, Year View는 Phase 2에서 별도 구현 예정.

### C-7. 11~12주차 — 마무리 + 오프라인 (Week 11-12)

```
Isar로 오프라인 캐싱을 구현해줘. 인터넷 없어도 캘린더가 보여야 해.
앱 전체 성능을 최적화해줘. 60fps 이하로 떨어지는 곳이 없는지 확인해.
빈 상태 화면(일정 없을 때)도 만들어줘.
```

---

## Phase D. 테스트 & 출시 (2~3주)

### D-1. 내부 테스트

- **iOS**: TestFlight — Apple Developer 계정 필요 ($99/년)
  1. https://developer.apple.com 에서 계정 생성
  2. Xcode에서 Archive → App Store Connect 업로드
  3. TestFlight에서 테스터 초대

- **Android**: Google Play Internal Testing
  1. https://play.google.com/console 에서 개발자 계정 생성 ($25 일회성)
  2. `flutter build appbundle` 로 AAB 파일 생성
  3. Internal Testing 트랙에 업로드

### D-2. 체크리스트

- [ ] 모든 P0 기능 동작 확인
- [ ] iOS / Android 양 플랫폼에서 동일한 UI 확인
- [ ] 오프라인 모드에서 기존 일정 조회 가능
- [ ] 알림이 정시에 도착하는지 확인
- [ ] 다크 모드 아닌 상태에서 모든 텍스트 가독성 확인
- [ ] 1,000개 이벤트 로드 시 스크롤 부드러움 확인
- [ ] 앱 크래시 없음 (Crashlytics 대시보드)
- [ ] 메모리 누수 없음 (Flutter DevTools)

### D-3. 앱 스토어 출시

- **App Store**
  - 스크린샷 6.7" + 5.5" 준비 (최소 3장)
  - 앱 설명, 키워드, 카테고리(Productivity) 설정
  - App Review 제출 → 보통 24~48시간

- **Google Play**
  - 스크린샷, feature graphic (1024×500) 준비
  - 앱 설명, 카테고리(Productivity)
  - 출시 → 보통 수 시간 ~ 1일

---

## 비용 정리

| 항목 | 비용 | 비고 |
|------|------|------|
| Apple Developer 계정 | $99/년 | iOS 출시 필수 |
| Google Play 개발자 계정 | $25 (일회성) | Android 출시 필수 |
| Firebase | 무료 (Spark 플랜) | MVP 단계에서 충분 |
| Claude Code | Pro 플랜 ($20/월) | 또는 Max 플랜 |
| Stitch | 무료 (현재) | Google Labs 프로젝트 |
| 도메인 (선택) | ~$12/년 | 웹사이트용 |
| **합계** | **~$156 (첫 해)** | 1인 개발 기준 |

---

## Claude Code 사용 팁

1. **한 번에 한 화면씩** — "캘린더 전체를 만들어줘"보다 "3-Day View 타임라인을 만들어줘"가 훨씬 좋은 결과를 냄
2. **Stitch 스크린 이름을 정확히** — "Stitch에서 calendar_3day 화면을 참고해서"처럼 구체적으로
3. **STRUCTURE.md를 먼저 읽히기** — 매 세션 시작 시 "STRUCTURE.md를 읽고 이 구조를 따라줘"
4. **검토 후 피드백** — 에뮬레이터에서 결과를 보고 "여백을 더 줘", "애니메이션이 너무 빨라" 등 구체적으로
5. **Git 커밋 자주** — 각 화면 완성 시마다 커밋해두면 문제 생겼을 때 되돌리기 쉬움
