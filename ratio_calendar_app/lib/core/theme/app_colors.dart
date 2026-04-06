import 'package:flutter/material.dart';

/// Ratio Calendar 컬러 시스템
/// DESIGN.md "Precision Architect" 기반
///
/// Surface Hierarchy (Section 2):
///   lowest (#ffffff) → main workspace
///   low (#f2f4f4) → navigation, structural
///   highest (#dde4e5) → callouts, utility panels
///
/// Ghost Border (Section 4):
///   outline_variant (#acb3b4) at 10–20% opacity
abstract final class AppColors {
  // ── Surface Hierarchy ──
  static const background = Color(0xFFFFFFFF);          // surface_container_lowest
  static const surface = Color(0xFFF2F4F4);              // surface_container_low
  static const surfaceHighest = Color(0xFFDDE4E5);       // surface_container_highest

  // ── Text / Ink ──
  static const textPrimary = Color(0xFF1A1A1A);          // Ink — 제목, 본문
  static const textSecondary = Color(0xFF8E8E93);        // Secondary — 라벨, 메타

  // ── Outline & Grid ──
  static const outlineVariant = Color(0xFFACB3B4);       // Ghost border 원색
  static final divider = outlineVariant.withValues(alpha: 0.15); // 10–20% opacity 그리드 라인

  // ── Calendar Accent Colors ──
  static const personal = Color(0xFF007AFF);             // Blue — Personal
  static const work = Color(0xFFFF3B30);                 // Red — Work
  static const shared = Color(0xFF34C759);               // Green — Shared

  // ── Event Category Colors ──
  // DESIGN.md §5: "desaturated bg tints (blue-50) + 4px left border (blue-600)"
  static const blueBorder = Color(0xFF2563EB);            // Sprint Planning 보더 (blue-600)
  static const blueBackground = Color(0xFFEFF6FF);        // Sprint Planning 배경 (blue-50)
  static const blueBackgroundHighlight = Color(0xFFDBEAFE); // Sprint Planning 강조 (blue-100)
  static const tealBorder = Color(0xFF0D9488);            // Design Sync 보더 (teal-600)
  static const tealBackground = Color(0xFFF0FDFA);        // Design Sync 배경 (teal-50)
  static const tealBackgroundHighlight = Color(0xFFCCFBF1); // Design Sync 강조 (teal-100)
  static const amberBorder = Color(0xFFD97706);           // Deep Work 보더 (amber-600)
  static const amberBackground = Color(0xFFFFFBEB);       // Deep Work 배경 (amber-50)
  static const amberBackgroundHighlight = Color(0xFFFEF3C7); // Deep Work 강조 (amber-100)
  static const orangeBorder = Color(0xFFEA580C);          // Team Standup 보더 (orange-600)
  static const orangeBackground = Color(0xFFFFF7ED);      // Team Standup 배경 (orange-50)
  static const orangeBackgroundHighlight = Color(0xFFFFEDD5); // Team Standup 강조 (orange-100)

  // ── Today Highlight ──
  static const todayHighlight = Color(0xFF003049);

  // ── System ──
  static const currentTimeIndicator = Color(0xFFFF3B30);
  static const fabBackground = Color(0xFF1A1A1A);        // 다크 모노크롬 FAB
  static const timeLabel = Color(0xFF8E8E93);             // 시간 라벨 — textSecondary와 동일

  // ── Today Column ──
  static const todayColumnTint = Colors.transparent;      // 오늘 컬럼 배경 tint 없음

  // ── Dark Mode (Phase 2) ──
  static const darkBackground = Color(0xFF1C1C1E);
  static const darkSurface = Color(0xFF2C2C2E);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E93);
}
