/// 캘린더 Local DataSource — Isar 로컬 캐시
///
/// 오프라인 지원: Firestore 데이터를 Isar에 캐싱
/// 앱 시작 시 로컬 데이터 먼저 표시, 이후 원격 동기화
///
/// 메서드:
///   - getCachedCalendars(workspaceId) → List<CalendarModel>
///   - cacheCalendars(calendars) → void
///   - clearCache(workspaceId) → void
