import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/timeline_view.dart';

/// 타임라인 스크롤 로직 mixin
/// - 현재 시각으로 자동 스크롤
/// - 블록 중심 애니메이션 스크롤
/// - 스크롤 시 슬롯 하이라이트 해제
mixin TimelineScrollHandler on ConsumerState<TimelineView> {
  late final ScrollController scrollController = ScrollController();

  /// auto-scroll 애니메이션 중 스크롤 리스너가 하이라이트를 해제하지 않도록 억제
  bool suppressScrollDismiss = false;

  /// 하위 mixin(GestureHandler)에서 구현
  void clearSlotHighlight();

  void initScrollHandler() {
    scrollController.addListener(_onUserScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToCurrentTime());
  }

  void disposeScrollHandler() {
    scrollController.removeListener(_onUserScroll);
    scrollController.dispose();
  }

  /// 스크롤 시 슬롯 하이라이트 해제 (auto-scroll 중에는 억제)
  void _onUserScroll() {
    if (suppressScrollDismiss) return;
    clearSlotHighlight();
  }

  /// 현재 시각 2시간 전으로 점프
  void scrollToCurrentTime() {
    final now = DateTime.now();
    final hourHeight = ref.read(hourHeightProvider);
    final targetOffset = ((now.hour - 2).clamp(0, 23)) * hourHeight;
    if (scrollController.hasClients) {
      scrollController.jumpTo(targetOffset);
    }
  }

  /// 타임라인 블록 중심이 Sheet 위 가시 영역 중앙에 오도록 스크롤
  void animateScrollToBlock(double blockTopPx, double blockHeightPx) {
    if (!scrollController.hasClients) return;

    final screenHeight = MediaQuery.of(context).size.height;

    final renderBox = context.findRenderObject() as RenderBox;
    final visibleTop = renderBox.localToGlobal(Offset.zero).dy;

    final sheetHeight = screenHeight * AppSizes.sheetEstimatedHeightFraction;
    final visibleBottom = screenHeight - sheetHeight;
    final visibleCenter = (visibleTop + visibleBottom) / 2;

    final blockCenter = blockTopPx + blockHeightPx / 2;
    const downwardBias = 50.0;
    final targetOffset =
        (blockCenter - (visibleCenter - visibleTop) - downwardBias).clamp(
      0.0,
      scrollController.position.maxScrollExtent,
    );

    unawaited(scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ));
  }
}
