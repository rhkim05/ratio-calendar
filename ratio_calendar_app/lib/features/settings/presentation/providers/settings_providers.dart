import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ratio_calendar/core/constants/enums.dart';

// ── SharedPreferences 인스턴스 ──

/// main.dart에서 override로 주입
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

// ── Settings Keys ──

class _Keys {
  static const defaultView = 'settings_default_view';
  static const startOfWeek = 'settings_start_of_week';
  static const eventReminders = 'settings_event_reminders';
  static const defaultReminderTime = 'settings_default_reminder_time';
  static const dailyAgenda = 'settings_daily_agenda';
  static const accentColorIndex = 'settings_accent_color_index';
}

// ── Settings State ──

class AppSettings {
  const AppSettings({
    this.defaultView = CalendarViewType.threeDay,
    this.startOfWeek = StartOfWeek.sunday,
    this.eventReminders = true,
    this.defaultReminderTime = AlertType.fifteenMinutes,
    this.dailyAgenda = false,
    this.accentColorIndex = 0,
  });

  final CalendarViewType defaultView;
  final StartOfWeek startOfWeek;
  final bool eventReminders;
  final AlertType defaultReminderTime;
  final bool dailyAgenda;
  final int accentColorIndex;

  AppSettings copyWith({
    CalendarViewType? defaultView,
    StartOfWeek? startOfWeek,
    bool? eventReminders,
    AlertType? defaultReminderTime,
    bool? dailyAgenda,
    int? accentColorIndex,
  }) {
    return AppSettings(
      defaultView: defaultView ?? this.defaultView,
      startOfWeek: startOfWeek ?? this.startOfWeek,
      eventReminders: eventReminders ?? this.eventReminders,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
      dailyAgenda: dailyAgenda ?? this.dailyAgenda,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
    );
  }
}

// ── Start of Week Enum ──

enum StartOfWeek {
  sunday,
  monday,
  saturday;

  String get label => switch (this) {
        sunday => 'Sunday',
        monday => 'Monday',
        saturday => 'Saturday',
      };

  /// 한 주의 첫째 요일 (DateTime.weekday 기준: 1=Mon, 7=Sun)
  int get weekday => switch (this) {
        sunday => DateTime.sunday,
        monday => DateTime.monday,
        saturday => DateTime.saturday,
      };
}

// ── Accent Colors ──

const accentColorOptions = [
  Color(0xFF007AFF), // Blue (Personal)
  Color(0xFFFF3B30), // Red (Work)
  Color(0xFF34C759), // Green (Shared)
  Color(0xFFFFCC00), // Yellow
  Color(0xFFAF52DE), // Purple
];

// ── Settings Provider ──

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    return _loadFromPrefs();
  }

  AppSettings _loadFromPrefs() {
    final viewIndex = _prefs.getInt(_Keys.defaultView);
    final weekIndex = _prefs.getInt(_Keys.startOfWeek);
    final reminders = _prefs.getBool(_Keys.eventReminders);
    final reminderIndex = _prefs.getInt(_Keys.defaultReminderTime);
    final agenda = _prefs.getBool(_Keys.dailyAgenda);
    final accentIndex = _prefs.getInt(_Keys.accentColorIndex);

    return AppSettings(
      defaultView: _safeEnum(CalendarViewType.values, viewIndex, CalendarViewType.threeDay),
      startOfWeek: _safeEnum(StartOfWeek.values, weekIndex, StartOfWeek.sunday),
      eventReminders: reminders ?? true,
      defaultReminderTime: _safeEnum(AlertType.values, reminderIndex, AlertType.fifteenMinutes),
      dailyAgenda: agenda ?? false,
      accentColorIndex: accentIndex != null &&
              accentIndex >= 0 &&
              accentIndex < accentColorOptions.length
          ? accentIndex
          : 0,
    );
  }

  /// enum index 안전 역직렬화 — null이거나 범위 밖이면 기본값 반환
  static T _safeEnum<T>(List<T> values, int? index, T defaultValue) {
    if (index == null || index < 0 || index >= values.length) {
      return defaultValue;
    }
    return values[index];
  }

  void setDefaultView(CalendarViewType view) {
    _prefs.setInt(_Keys.defaultView, view.index);
    state = state.copyWith(defaultView: view);
  }

  void setStartOfWeek(StartOfWeek week) {
    _prefs.setInt(_Keys.startOfWeek, week.index);
    state = state.copyWith(startOfWeek: week);
  }

  void setEventReminders(bool enabled) {
    _prefs.setBool(_Keys.eventReminders, enabled);
    state = state.copyWith(eventReminders: enabled);
  }

  void setDefaultReminderTime(AlertType alert) {
    _prefs.setInt(_Keys.defaultReminderTime, alert.index);
    state = state.copyWith(defaultReminderTime: alert);
  }

  void setDailyAgenda(bool enabled) {
    _prefs.setBool(_Keys.dailyAgenda, enabled);
    state = state.copyWith(dailyAgenda: enabled);
  }

  void setAccentColorIndex(int index) {
    _prefs.setInt(_Keys.accentColorIndex, index);
    state = state.copyWith(accentColorIndex: index);
  }
}

// ── Derived Providers ──

/// 현재 선택된 accent 색상
final accentColorProvider = Provider<Color>((ref) {
  final index = ref.watch(
    settingsProvider.select((s) => s.accentColorIndex),
  );
  return accentColorOptions[index.clamp(0, accentColorOptions.length - 1)];
});
