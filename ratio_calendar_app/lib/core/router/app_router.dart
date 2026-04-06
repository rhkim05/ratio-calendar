import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ratio_calendar/features/calendar/presentation/screens/calendar_main_screen.dart';
import 'package:ratio_calendar/features/settings/presentation/screens/settings_screen.dart';
import 'package:ratio_calendar/features/side_menu/presentation/screens/side_menu_screen.dart';

/// 라우트 경로 상수
abstract final class AppRoutes {
  static const home = '/';
  static const sideMenu = '/menu';
  static const settings = '/settings';
  static const eventCreate = '/event/create';
  static const eventDetail = '/event/:id';
  static const eventEdit = '/event/:id/edit';
  static const login = '/auth/login';
  static const signup = '/auth/signup';
}

/// GoRouter 인스턴스
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const CalendarMainScreen(),
    ),
    GoRoute(
      path: AppRoutes.sideMenu,
      builder: (context, state) => const SideMenuScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
    ),
  ],
);
