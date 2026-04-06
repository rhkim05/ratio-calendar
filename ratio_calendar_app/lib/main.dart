import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

/// Ratio Calendar — 미니멀리즘 캘린더 앱
/// "Less, but better." — Dieter Rams
///
/// 진입점:
/// 1. Firebase 초기화
/// 2. Isar(로컬 DB) 초기화
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

  // TODO: Isar 인스턴스 열기
  // TODO: FCM 토큰 등록

  runApp(
    const ProviderScope(
      child: RatioCalendarApp(),
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
