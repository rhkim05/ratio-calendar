/// 이벤트 Remote DataSource — Firestore 연동
///
/// Firestore 컬렉션 구조:
///   workspaces/{workspaceId}/calendars/{calendarId}/events/{eventId}
///
/// 메서드:
///   - fetchEvents(calendarId, startDate, endDate) → List<EventModel>
///   - addEvent(calendarId, data) → EventModel
///   - updateEvent(calendarId, eventId, data) → void
///   - deleteEvent(calendarId, eventId) → void
///   - watchEvents(calendarId, dateRange) → Stream<List<EventModel>>
///   - searchEvents(workspaceId, query) → List<EventModel>  (Phase 2)
