/// 이벤트 Local DataSource — Isar 로컬 캐시
///
/// 오프라인 지원: Firestore 이벤트를 Isar에 캐싱
///
/// 메서드:
///   - getCachedEvents(calendarId, startDate, endDate) → List<EventModel>
///   - cacheEvents(events) → void
///   - clearCache(calendarId) → void
