/// 캘린더 Remote DataSource — Firestore 연동
///
/// Firestore 컬렉션 구조:
///   workspaces/{workspaceId}/calendars/{calendarId}
///
/// 메서드:
///   - fetchCalendars(workspaceId) → List<CalendarModel>
///   - addCalendar(workspaceId, data) → CalendarModel
///   - updateCalendar(workspaceId, calendarId, data) → void
///   - deleteCalendar(workspaceId, calendarId) → void
///   - watchCalendars(workspaceId) → Stream<List<CalendarModel>>
