import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/calendar/data/datasources/calendar_local_datasource.dart';
import 'features/calendar/data/repositories/calendar_repository_impl.dart';
import 'features/calendar/presentation/providers/calendar_providers.dart';
import 'features/event/data/datasources/event_local_datasource.dart';
import 'features/event/data/repositories/event_repository_impl.dart';
import 'features/event/presentation/providers/event_providers.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'firebase_options.dart';

/// Ratio Calendar — 미니멀리즘 캘린더 앱
/// "Less, but better." — Dieter Rams
///
/// 진입점:
/// 1. Firebase 초기화
/// 2. SQLite(로컬 DB) 초기화
/// 3. Riverpod ProviderScope로 앱 래핑
/// 4. GoRouter로 네비게이션 관리
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 시스템 UI 투명 처리 (edge-to-edge)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // SharedPreferences 초기화
  final prefs = await SharedPreferences.getInstance();

  // SQLite 데이터베이스 초기화
  final db = await AppDatabase.instance.database;

  // DataSource & Repository 생성
  final eventLocalDS = EventLocalDataSource(db);
  final calendarLocalDS = CalendarLocalDataSource(db);
  final eventRepo = EventRepositoryImpl(localDataSource: eventLocalDS);
  final calendarRepo = CalendarRepositoryImpl(localDataSource: calendarLocalDS);

  // TODO: FCM 토큰 등록

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        eventRepositoryProvider.overrideWithValue(eventRepo),
        calendarRepositoryProvider.overrideWithValue(calendarRepo),
      ],
      child: const RatioCalendarApp(),
    ),
  );
}

class RatioCalendarApp extends StatelessWidget {
  const RatioCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ratio Calendar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // Phase 2에서 시스템 설정 연동
      routerConfig: appRouter,
    );
  }
}
