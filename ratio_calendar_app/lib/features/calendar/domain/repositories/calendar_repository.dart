/// 캘린더 Repository 인터페이스 (추상 클래스)
/// Domain 레이어에서 정의, Data 레이어에서 구현
///
/// 메서드:
///   - getCalendars(workspaceId) → List<CalendarEntity>
///   - getCalendarById(id) → CalendarEntity?
///   - createCalendar(calendar) → CalendarEntity
///   - updateCalendar(calendar) → CalendarEntity
///   - deleteCalendar(id) → void
///   - toggleVisibility(id, isVisible) → void
