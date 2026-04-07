import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Ratio Calendar 타이포그래피
/// DESIGN.md §3: "The system relies exclusively on Inter"
///
/// Scale Ground Truth:
///   Display:       24px / Black (900)
///   Headline:      18px / Black (900)
///   Body:          14px / Regular (400)
///   Caption/Micro: 10–12px / Bold (700) or Black (900)
///
/// Headers → heavy weights + tight tracking (-0.03em)
/// Technical Labels → small, ALL-CAPS, wide tracking (0.15–0.2em)
abstract final class AppTypography {
  // ── 월 타이틀 — Technical Label 스타일, ALL CAPS, wide tracking ──
  // "APRIL 2026" — Stitch: 작고 넓은 letter-spacing
  static final monthTitle = GoogleFonts.bebasNeue(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 2.5, // ~0.18em — wide tracking
    height: 1.2,
  );

  // ── 날짜 숫자 — Light, 44px (Stitch: 크고 가벼운 느낌) ──
  // 헤더의 주인공 — 시각적 앵커
  static final dateNumber = GoogleFonts.dmSans(
    fontSize: 33,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // ── 이벤트 제목 — Body scale, Medium ──
  static final eventTitle = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ── 이벤트 시간 — Caption/Micro scale ──
  static final eventTime = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ── 요일 라벨 — Technical Label, ALL-CAPS, wide tracking ──
  // DESIGN.md §3: 8–10px, all-caps, 0.15–0.2em
  static final dayLabel = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 2.0, // ~0.2em — wide tracking
    height: 1.3,
  );

  // ── 섹션 라벨 — Technical Label ──
  static final sectionLabel = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 2.0,
    height: 1.3,
  );

  // ── Display — Bottom Sheet 제목 ──
  // DESIGN.md: Display 24px / Black
  static final sheetTitle = GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.42, // -0.03em tight tracking
    height: 1.3,
  );

  // ── Headline ──
  // DESIGN.md: Headline 18px / Black
  static final headline = GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.54, // -0.03em
    height: 1.3,
  );

  // ── Body ──
  // DESIGN.md: Body 14px / Regular
  static final body = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ── Body Small ──
  // 13px — Auth, Error, Link 등 보조 본문
  static final bodySmall = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ── Caption / Micro ──
  // DESIGN.md: 10–12px / Bold or Black
  static final caption = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}
