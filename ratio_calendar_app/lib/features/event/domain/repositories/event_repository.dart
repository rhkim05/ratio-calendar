/// 이벤트 Repository 인터페이스 (추상 클래스)
/// Domain 레이어에서 정의, Data 레이어에서 구현
///
/// 메서드:
///   - getEventsByDateRange(start, end, calendarIds) → List<EventEntity>
///   - getEventById(id) → EventEntity?
///   - createEvent(event) → EventEntity
///   - updateEvent(event) → EventEntity
///   - deleteEvent(id) → void
///   - searchEvents(query) → List<EventEntity>  (Phase 2)
///   - getRecurringInstances(eventId, range) → List<EventEntity>
