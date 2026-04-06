import 'package:ratio_calendar/features/calendar/domain/entities/calendar_entity.dart';

/// 캘린더 Repository 인터페이스
abstract class CalendarRepository {
  Future<List<CalendarEntity>> getAllCalendars();
  Future<CalendarEntity?> getCalendarById(String id);
  Future<void> createCalendar(CalendarEntity calendar);
  Future<void> updateCalendar(CalendarEntity calendar);
  Future<void> deleteCalendar(String id);
  Future<void> ensureDefaults();
}
