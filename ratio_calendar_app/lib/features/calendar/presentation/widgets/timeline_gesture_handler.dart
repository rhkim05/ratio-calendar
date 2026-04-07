import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_scroll_handler.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_view.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 타임라인 제스처 mixin
/// - 핀치 줌 (Listener 기반, gesture arena 미참여)
/// - 롱프레스 슬롯 선택 / 드래그 범위 조절
/// - 빈 영역 탭 → 하이라이트 또는 이벤트 생성
/// - 이벤트 탭 → 강조 + 스크롤 + 콜백
mixin TimelineGestureHandler
    on ConsumerState<TimelineView>, TimelineScrollHandler {
  /// 현재 상세 Sheet가 열려있는 이벤트 ID (강조 표시용)
  String? highlightedEventId;

  /// 슬롯 하이라이트 상태 — 롱프레스로 활성화, 드래그로 범위 조절
  DateTime? highlightedDate;
  int highlightStartMin = 0; // 분 단위 (0–1440)
  int highlightEndMin = 0;
  int _longPressAnchorMin = 0; // 드래그 기준점

  // ── 핀치 줌 상태 ──
  final Map<int, Offset> activePointers = {};
  double _pinchBaseHourHeight = 0;
  double _pinchInitialDistance = 0;
  bool isPinchActive = false;

  // ── 10분 스냅 헬퍼 ──
  static int _snapTo10Min(int minutes) =>
      ((minutes / 10).round() * 10).clamp(0, 24 * 60);

  @override
  void clearSlotHighlight() {
    if (highlightedDate != null) {
      setState(() => highlightedDate = null);
    }
  }

  // ── 핀치 줌 핸들러 ──

  void onPointerDown(PointerDownEvent event) {
    activePointers[event.pointer] = event.localPosition;
    if (activePointers.length == 2 && !isPinchActive) {
      isPinchActive = true;
      final pts = activePointers.values.toList();
      _pinchInitialDistance = (pts[0] - pts[1]).distance;
      _pinchBaseHourHeight = ref.read(hourHeightProvider);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    activePointers[event.pointer] = event.localPosition;
    if (!isPinchActive || activePointers.length < 2) return;

    final pts = activePointers.values.toList();
    final currentDistance = (pts[0] - pts[1]).distance;
    if (_pinchInitialDistance < 1) return;

    final scale = currentDistance / _pinchInitialDistance;
    final oldHourHeight = ref.read(hourHeightProvider);
    final newHourHeight = (_pinchBaseHourHeight * scale)
        .clamp(HourHeight.minHeight, HourHeight.maxHeight);

    if ((newHourHeight - oldHourHeight).abs() < 0.01) return;

    // Anchor point: 핀치 포컬 포인트가 가리키는 시간(분)을 유지
    final focalPointY = (pts[0].dy + pts[1].dy) / 2;
    final currentScroll = scrollController.offset;
    final anchorMinutes = (currentScroll + focalPointY) / oldHourHeight * 60;

    ref.read(hourHeightProvider.notifier).set(newHourHeight);

    final newScroll = anchorMinutes * newHourHeight / 60 - focalPointY;
    final maxScroll =
        24 * newHourHeight - scrollController.position.viewportDimension;
    scrollController
        .jumpTo(newScroll.clamp(0.0, maxScroll > 0 ? maxScroll : 0.0));
  }

  void onPointerUp(PointerUpEvent event) {
    activePointers.remove(event.pointer);
    if (activePointers.length < 2) isPinchActive = false;
  }

  void onPointerCancel(PointerCancelEvent event) {
    activePointers.remove(event.pointer);
    if (activePointers.length < 2) isPinchActive = false;
  }

  // ── 롱프레스 제스처 핸들러 ──

  void handleLongPressStart(DateTime date, int rawMinute, double hourHeight) {
    final hour = (rawMinute / 60).floor().clamp(0, 23);
    highlightedEventId = null;
    setState(() {
      highlightedDate = date;
      highlightStartMin = hour * 60;
      highlightEndMin = min((hour + 1) * 60, 24 * 60);
      _longPressAnchorMin = _snapTo10Min(rawMinute);
    });
    HapticFeedback.mediumImpact();
  }

  void handleLongPressMove(DateTime date, int rawMinute) {
    if (highlightedDate == null) return;
    final snapped = _snapTo10Min(rawMinute);
    setState(() {
      highlightStartMin = min(_longPressAnchorMin, snapped);
      highlightEndMin = max(_longPressAnchorMin, snapped);
      if (highlightEndMin - highlightStartMin < 10) {
        highlightEndMin = highlightStartMin + 10;
      }
    });
  }

  /// 빈 영역 탭: 하이라이트 범위 내면 이벤트 생성, 밖이면 1시간 하이라이트
  void handleTapAt(DateTime date, int rawMinute) {
    if (highlightedDate != null &&
        highlightedDate!.year == date.year &&
        highlightedDate!.month == date.month &&
        highlightedDate!.day == date.day &&
        rawMinute >= highlightStartMin &&
        rawMinute < highlightEndMin) {
      _onHighlightedSlotTap(date);
    } else {
      final hour = (rawMinute / 60).floor().clamp(0, 23);
      // setState 전에 클리어하여 EventBlock AnimatedContainer 깜빡임 방지
      highlightedEventId = null;
      setState(() {
        highlightedDate = date;
        highlightStartMin = hour * 60;
        highlightEndMin = min((hour + 1) * 60, 24 * 60);
      });
    }
  }

  /// 롱프레스 종료 → 바로 Sheet 열기
  void handleLongPressEnd(DateTime date) {
    if (highlightedDate == null) return;
    _onHighlightedSlotTap(date);
  }

  /// 하이라이트된 슬롯 탭 → 자동 스크롤 + Sheet 열기
  Future<void> _onHighlightedSlotTap(DateTime date) async {
    final hourHeight = ref.read(hourHeightProvider);
    suppressScrollDismiss = true;
    final blockTop = highlightStartMin * hourHeight / 60;
    final blockHeight = (highlightEndMin - highlightStartMin) * hourHeight / 60;
    animateScrollToBlock(blockTop, blockHeight);

    final startTime = DateTime(
      date.year, date.month, date.day,
      highlightStartMin ~/ 60, highlightStartMin % 60,
    );
    final endTime = DateTime(
      date.year, date.month, date.day,
      highlightEndMin ~/ 60, highlightEndMin % 60,
    );

    await widget.onEmptySlotTap?.call(startTime, endTime);

    suppressScrollDismiss = false;
    if (mounted) {
      setState(() => highlightedDate = null);
    }
  }

  /// 이벤트 탭 시: 강조 + 스크롤 애니메이션 + onEventTap 콜백
  Future<void> onEventTapWithScroll(EventEntity event) async {
    final hourHeight = ref.read(hourHeightProvider);
    setState(() {
      highlightedEventId = event.id;
      highlightedDate = null;
    });

    final startMinutes = event.startTime.hour * 60 + event.startTime.minute;
    final blockTop = startMinutes * hourHeight / 60;
    final durationMinutes = event.endTime.difference(event.startTime).inMinutes;
    final blockHeight = durationMinutes * hourHeight / 60;

    animateScrollToBlock(blockTop, blockHeight);

    await widget.onEventTap?.call(event);

    if (mounted) {
      highlightedEventId = null;
      setState(() {});
    }
  }
}
