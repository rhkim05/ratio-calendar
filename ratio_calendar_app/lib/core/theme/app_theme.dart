import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Ratio Calendar 앱 전체 ThemeData
/// DESIGN.md "Precision Architect" 기반
///
/// §4 Elevation:
///   Low  — 0 1px 2px 0 rgba(0,0,0,0.05)
///   High — 0 25px 50px -12px rgba(0,0,0,0.25)
///
/// §5 FABs: "generous full rounding, dark monochromatic"
/// §5 Buttons: "sharp-edged (0.25rem), high-contrast Ink/White"
abstract final class AppTheme {
  // ── Light Theme ──
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,

        // ── Dynamic color 완전 비활성화 ──
        // colorSchemeSeed 사용 금지, 모든 색상 명시적 고정
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.personal,           // #007AFF 고정
          onPrimary: Colors.white,
          secondary: AppColors.personal,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: Color(0xFFFF3B30),
          onError: Colors.white,
          outlineVariant: AppColors.outlineVariant,
          surfaceContainerHighest: AppColors.surfaceHighest,
        ),

        // ── Material splash/ripple 비활성화 ──
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,

        // ── Platform-adaptive 동작 통일 (iOS 스타일 제거) ──
        platform: TargetPlatform.android,

        // Inter 기본 폰트
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: AppTypography.sheetTitle,
          headlineLarge: AppTypography.headline,
          headlineMedium: AppTypography.monthTitle,
          titleMedium: AppTypography.eventTitle,
          bodyMedium: AppTypography.body,
          bodySmall: AppTypography.eventTime,
          labelSmall: AppTypography.sectionLabel,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          titleTextStyle: AppTypography.monthTitle,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          showDragHandle: true,
        ),
        // §5: FABs — generous rounding, dark monochromatic
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.fabBackground,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.divider,
          thickness: 0.5,
        ),
        // §5: Buttons — sharp-edged, high-contrast
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: AppColors.background,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        // §5: Inputs — minimalist containers
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      );

  // ── Dark Theme (Phase 2) ──
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.personal,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        // TODO(phase2): Dark 테마 세부 설정
      );
}
