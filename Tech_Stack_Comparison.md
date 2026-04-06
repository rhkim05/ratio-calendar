# Ratio Calendar — 기술 스택 비교 분석

**Version**: 2.0
**Date**: 2026-04-02
**목적**: Flutter vs React Native vs Native(Swift+Kotlin) 객관적 수치 기반 비교

---

## 1. 핵심 성능 벤치마크

### 1.1 앱 시작 시간 (Cold Start)

사용자가 앱 아이콘을 탭한 후 첫 화면이 렌더링되기까지의 시간이다. 캘린더 앱은 매일 여러 번 열기 때문에 체감 품질에 직접 영향을 준다.

| 프레임워크 | Cold Start | 비고 |
|-----------|-----------|------|
| **Native (Swift)** | ~0.9초 | 첫 프레임 50ms 이내 렌더링 |
| **Native (Kotlin)** | ~1.0초 | — |
| **Flutter** | ~1.2초 | Impeller 엔진 적용 시 개선 |
| **React Native** | 1.2~2.0초 | Hermes 엔진, 번들 크기에 의존 |

> **출처**: SynergyBoat 2025 벤치마크, Chandru Medium 2025

**Ratio Calendar 영향**: 직장인/학생이 하루 5~10회 앱을 열 때, Native 대비 Flutter는 약 0.3초 차이(인지하기 어려운 수준). React Native 최악 케이스(2초)는 체감 지연 발생 가능.

---

### 1.2 프레임 레이트 (FPS)

캘린더 앱에서 타임라인 스크롤, 뷰 전환, Bottom Sheet 등 모든 인터랙션의 부드러움을 결정한다.

| 시나리오 | Flutter | React Native | Native |
|---------|---------|--------------|--------|
| 일반 애니메이션 | 60~120 FPS | 55~60 FPS | 60 FPS |
| 복잡한 애니메이션 | 117.75 FPS | 45~50 FPS | 60 FPS |
| 1,000개 카드 리스트 | ~25ms/프레임 | 35~50ms/프레임 | <20ms/프레임 |
| 프레임 래스터화 (iOS) | 1.72ms | — | 간헐적 예산 초과 |

> **출처**: Orient Software, ThoughtBot, SynergyBoat 2025

**주목**: Flutter의 Impeller 엔진은 복잡한 애니메이션에서 117.75 FPS를 기록하며, Native의 60 FPS를 초과한다. 자체 렌더링 파이프라인이 플랫폼 compositor를 거치지 않아 더 높은 프레임 수를 달성. React Native는 JS-UI 스레드 간 경합으로 복잡한 애니메이션에서 45~50 FPS까지 하락.

**Ratio Calendar 영향**: 3-Day 뷰 스크롤과 Bottom Sheet 트랜지션은 "중간~복잡 애니메이션" 범주. Flutter가 가장 안정적이며, React Native는 이벤트 많은 주간 뷰에서 프레임 드롭 위험.

---

### 1.3 메모리 사용량 (RAM)

| 프레임워크 | 유휴 상태 | 활성 사용 | 최대 메모리 |
|-----------|----------|----------|-----------|
| **Native (Swift)** | ~100MB | ~100MB | 기준선 |
| **Native (Kotlin)** | ~100MB | ~100MB | 기준선 |
| **Flutter** | ~110MB | ~200MB | 253MB |
| **React Native** | — | — | 139MB |

> **출처**: Orient Software, Medium Flutter 2026, Ali Mert Guler

**분석**: Flutter 유휴 110MB는 Native의 100MB와 10% 차이 — 현대 기기(4GB+ RAM)에서 실질적 차이 없음. 캘린더 앱은 대량 미디어를 처리하지 않으므로 메모리는 세 프레임워크 모두 무관.

---

### 1.4 앱 바이너리 크기

| 앱 유형 | Flutter | React Native | Native |
|--------|---------|--------------|--------|
| 기본 앱 (Hello World) | 5.6MB | 8MB | ~2MB |
| 중간 복잡도 (Android APK) | 16.8MB | 21.9MB (+30%) | ~10MB |
| 중간 복잡도 (iOS IPA) | 71.5MB | 112.3MB (+57%) | ~40MB |
| Lottie 애니메이션 포함 | 7.6MB | 18.5MB (+144%) | — |

> **출처**: Tech Insider 2026, SynergyBoat, TheDroidsOnRoids

**분석**: Flutter는 React Native보다 일관적으로 30~57% 작다. iOS에서 React Native 112.3MB는 셀룰러 다운로드 경고 발생(100MB 초과). Ratio Calendar는 미니멀 앱이므로 작은 크기가 브랜드 이미지와 일치. Flutter 기준 Android 20MB 이내, iOS 80MB 이내 예상.

---

### 1.5 CPU & 배터리 소모

| 프레임워크 | CPU (애니메이션) | CPU (일반) | 배터리 (mAh) |
|-----------|-----------------|------------|-------------|
| **Native Android** | 기준선 | 기준선 | 49.7 mAh |
| **Flutter** | 5.4% | 43.42% | 65.28 mAh (+31%) |
| **React Native** | 11.7% | 52.92% | 79.01 mAh (+59%) |

> **출처**: Orient Software, inVerita

**분석**: Flutter는 애니메이션 중 CPU를 Native 절반 수준으로 사용하면서 더 높은 FPS 달성 (Impeller GPU 가속 효율). React Native는 JS 런타임 오버헤드로 CPU/배터리 소모 최대. 일일 10~15분 사용 기준 실제 배터리 차이는 ~5mAh로 미미.

---

## 2. 개발 효율성

### 2.1 개발 속도 & 비용

| 항목 | Flutter | React Native | Native (iOS+Android) |
|------|---------|--------------|---------------------|
| **코드 재사용률** | 95%+ | 80~90% | 0% (별도 코드베이스) |
| **MVP 기간** | 3~4개월 | 3~4개월 | 6~8개월 |
| **Native 대비 시간 절감** | 35~60% | 30~50% | 기준선 (1x) |
| **개발 비용 (중간 복잡도)** | $30K~$80K | $30K~$80K | $80K~$160K |
| **개발자 시급 (US)** | $150~$250/hr | $150~$250/hr | $150~$300/hr (×2 팀) |

> **출처**: Koderspedia 2025, SolGuruz 2025, Google 개발자 인사이트

**Ratio Calendar 비용 추정**:

| 프레임워크 | MVP 비용 | MVP 기간 | 연간 유지보수 |
|-----------|---------|---------|-------------|
| Flutter | $40K~$60K | 12주 | $8K~$15K |
| React Native | $40K~$65K | 12~14주 | $10K~$18K |
| Native | $80K~$120K | 20~24주 | $20K~$35K |

### 2.2 개발자 생태계

| 지표 | Flutter | React Native | Native |
|------|---------|--------------|--------|
| **GitHub Stars** | 170,000+ | 120,000+ | — |
| **Stack Overflow 사용률 (2025)** | 9.12% | 8.43% | Swift 4.7% / Kotlin 8.9% |
| **크로스플랫폼 시장점유율** | 46% | 35% | — |
| **상위 500 미국 앱 점유율** | 5.24% | 12.57% | ~82% |
| **앱 수익 (Q4 2024)** | ~$283M | ~$287M | — |
| **개발자 만족도** | 더 높음 | 높음 | 가장 높음 |

> **출처**: Stack Overflow 2025, Statista, TechAhead 2026

---

## 3. 사용자 경험 (UX) 품질

### 3.1 애니메이션 품질

| 항목 | Flutter | React Native | Native |
|------|---------|--------------|--------|
| **렌더링 방식** | 자체 엔진 (Impeller/Skia) | JS → Native 브릿지 | 플랫폼 네이티브 |
| **120Hz 디스플레이** | 네이티브 수준 | 가능하나 최적화 필요 | 완전 지원 |
| **프레임 래스터화** | ~50% 감소 (Impeller) | — | 기준선 |
| **Jank 빈도** | 매우 낮음 | 중간 (최적화 필수) | 매우 낮음 |

> **출처**: ForesightMobile 2026, Dev.to Impeller 분석

Flutter Impeller 엔진은 2026년 기준 "Native와 구별 불가능"한 애니메이션을 달성. 셰이더 사전 컴파일로 첫 실행에서도 jank 미발생.

### 3.2 플랫폼 네이티브 느낌

| 항목 | Flutter | React Native | Native |
|------|---------|--------------|--------|
| **플랫폼 UI 위젯** | Material + Cupertino (모방) | 실제 네이티브 위젯 | 완전 네이티브 |
| **제스처** | 자체 구현 (자유 커스터마이징) | 네이티브 제스처 시스템 | 완전 네이티브 |
| **시스템 통합** | Platform Channel 필요 | Native Module 필요 | 직접 접근 |

**Ratio Calendar 영향**: 커스텀 미니멀 디자인을 사용하므로 플랫폼 기본 위젯에 의존하지 않는다. Flutter의 자체 렌더링이 오히려 장점 — 양 플랫폼에서 완전히 동일한 디자인 보장. React Native의 네이티브 위젯 장점은 커스텀 UI 앱에서는 플랫폼 간 불일치 관리 비용이 됨.

### 3.3 앱 안정성

| 지표 | 수치 | 설명 |
|------|------|------|
| Flutter 크래시율 변화 | 15% 감소 | 2025년 메모리 관리 개선 |
| 성능 개선 후 평점 변화 | 4.2 → 4.7 | Play Store 사례 |
| 모니터링 도구 효과 | 30% 크래시 감소 | Firebase/Sentry 1개월 내 |
| 1초 지연당 이탈률 | +7% | 모든 프레임워크 동일 |
| 3초 이상 로딩 포기율 | 53% | 모든 프레임워크 동일 |

> **출처**: UXCam 2025, Medium Flutter 최적화

---

## 4. Ratio Calendar 특화 분석

### 4.1 가중 점수 (5점 만점)

| 기능 | Flutter | RN | Native | 가중치 |
|------|---------|-----|--------|--------|
| 3-Day 타임라인 스크롤 (60fps) | 5 | 4 | 5 | ×3 (핵심) |
| Bottom Sheet 애니메이션 | 5 | 4 | 5 | ×3 (핵심) |
| 양 플랫폼 디자인 일관성 | 5 | 3 | 3 | ×3 (핵심) |
| 개발 속도 (12주 MVP) | 5 | 4 | 2 | ×3 (핵심) |
| 뷰 전환 트랜지션 | 5 | 3 | 5 | ×2 |
| 대량 이벤트 렌더링 | 5 | 3 | 5 | ×2 |
| 홈 화면 위젯 | 3 | 3 | 5 | ×2 |
| 비용 효율성 | 5 | 5 | 2 | ×2 |
| 푸시 알림 | 5 | 5 | 5 | ×1 |
| 오프라인 동기화 | 4 | 4 | 5 | ×1 |
| **합계 (110점 만점)** | **107** | **81** | **91** | |

### 4.2 시나리오별 권장

**시나리오 A: "빠르게 시장 검증" → Flutter (권장)**
- MVP 12주 + 비용 $40K~$60K
- 양 플랫폼 동시 출시
- 미니멀 디자인 픽셀 단위 완벽 구현
- 위젯은 Phase 2에서 네이티브 코드 추가

**시나리오 B: "최고의 UX가 절대적" → Native**
- MVP 20~24주 + 비용 $80K~$120K
- 각 플랫폼 최적화된 경험
- 홈 화면 위젯 완전 지원
- 장기 기술 부채 최소

**시나리오 C: "웹 개발팀 보유" → React Native**
- MVP 12~14주 + 비용 $40K~$65K
- JavaScript 생태계 활용
- 웹 앱 확장 시 코드 60~70% 재사용
- 성능 최적화에 추가 공수 필요

---

## 5. 최종 권장안

### Ratio Calendar에는 Flutter를 권장한다

**성능**: Cold Start 1.2초 — Native 대비 0.2~0.3초 차이로 인지 불가. 복잡한 애니메이션 117.75 FPS (Native 60 FPS 초과). 프레임 렌더링 25ms (React Native 35~50ms 대비 50%+ 빠름).

**비용**: Native 대비 50~60% 절감 ($40K~$60K vs $80K~$120K). 12주 vs 20~24주. 95%+ 코드 재사용으로 유지보수 비용도 절반.

**UX**: 커스텀 미니멀 디자인 사용 → Flutter 자체 렌더링이 양 플랫폼에서 픽셀 단위 동일 경험 보장. Impeller 엔진 = "Native와 구별 불가능" (2026년 평가).

**유일한 약점**: 홈 화면 위젯에 SwiftUI/Jetpack Glance 네이티브 코드 필요 → Phase 2에서 1~2개월 추가 공수로 해결.

---

## 6. 참고 자료

| 출처 | URL |
|------|-----|
| SynergyBoat 2025 벤치마크 | synergyboat.com/blog/flutter-vs-react-native-vs-native-performance-benchmark-2025 |
| inVerita 성능 비교 | inveritasoft.com/blog/flutter-vs-react-native-vs-native-deep-performance-comparison |
| Orient Software 성능 비교 | orientsoftware.com/blog/flutter-vs-react-native-performance |
| ThoughtBot 성능 비교 | thoughtbot.com/blog/examining-performance-differences-between-native-flutter-and-react-native |
| Medium Flutter 2026 벤치마크 | medium.com/@yash22202/flutter-just-beat-native-ios-performance |
| Stack Overflow 2025 설문 | survey.stackoverflow.co/2025/technology |
| TechAhead 2026 비교 | techaheadcorp.com/blog/flutter-vs-react-native-in-2026 |
| Koderspedia 개발 비용 | koderspedia.com/flutter-app-development-cost |
| ForesightMobile Impeller | foresightmobile.com/blog/why-flutter-will-outperform-the-competition-in-2026 |
| UXCam 크래시 리포팅 | uxcam.com/blog/flutter-crash-reporting-best-tools-and-techniques-2025 |
