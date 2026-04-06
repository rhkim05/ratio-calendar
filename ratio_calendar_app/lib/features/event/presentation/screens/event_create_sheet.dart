import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';
import 'package:ratio_calendar/features/event/presentation/providers/event_providers.dart';

/// 일정 생성 Bottom Sheet
///
/// FAB(+) 또는 타임라인 빈 공간 더블탭 시 아래에서 올라옴.
/// 저장 시 로컬 상태에 저장하고 캘린더에 즉시 반영.
class EventCreateSheet extends ConsumerStatefulWidget {
  const EventCreateSheet({
    super.key,
    this.initialDate,
    this.initialStartTime,
    this.initialEndTime,
  });

  /// 초기 날짜 (타임라인 탭 시 전달)
  final DateTime? initialDate;

  /// 초기 시작 시간 (타임라인 탭 시 전달)
  final DateTime? initialStartTime;

  /// 초기 종료 시간 (타임라인 드래그 선택 시 전달)
  final DateTime? initialEndTime;

  /// Bottom Sheet를 표시하는 헬퍼 메서드
  static Future<void> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? initialStartTime,
    DateTime? initialEndTime,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventCreateSheet(
        initialDate: initialDate,
        initialStartTime: initialStartTime,
        initialEndTime: initialEndTime,
      ),
    );
  }

  @override
  ConsumerState<EventCreateSheet> createState() => _EventCreateSheetState();
}

class _EventCreateSheetState extends ConsumerState<EventCreateSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();

  late DateTime _selectedDate;
  late DateTime _startTime;
  late DateTime _endTime;
  RecurrenceType _recurrence = RecurrenceType.never;
  AlertType _alert = AlertType.fifteenMinutes;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initialDate ?? DateTime(now.year, now.month, now.day);

    if (widget.initialStartTime != null) {
      _startTime = widget.initialStartTime!;
      _endTime = widget.initialEndTime ?? _startTime.add(const Duration(hours: 1));
    } else {
      // 현재 시간의 다음 정시로 초기화
      final nextHour = now.hour + 1;
      _startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        nextHour.clamp(0, 23),
      );
      _endTime = _startTime.add(const Duration(hours: 1));
    }

    // 시트 올라온 후 제목 필드에 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final event = EventEntity(
      id: 'local-${now.millisecondsSinceEpoch}',
      title: title,
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      recurrence: _recurrence,
      alert: _alert,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      calendarId: 'sprint', // 기본 캘린더
      createdAt: now,
      updatedAt: now,
    );

    ref.read(localEventsProvider.notifier).add(event);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // 시간도 새 날짜에 맞게 업데이트
        _startTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
        _endTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked != null) {
      setState(() {
        final newTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
        if (isStart) {
          _startTime = newTime;
          // 종료 시간이 시작보다 앞이면 자동 조정
          if (_endTime.isBefore(_startTime) ||
              _endTime.isAtSameMomentAs(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          _endTime = newTime;
        }
      });
    }
  }

  void _pickRecurrence() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: RecurrenceType.values
              .where((r) => r != RecurrenceType.custom)
              .map(
                (r) => ListTile(
                  title: Text(
                    _recurrenceLabel(r),
                    style: AppTypography.body,
                  ),
                  trailing: r == _recurrence
                      ? const Icon(Icons.check, size: 20, color: AppColors.textPrimary)
                      : null,
                  onTap: () {
                    setState(() => _recurrence = r);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _pickAlert() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AlertType.values
              .map(
                (a) => ListTile(
                  title: Text(
                    _alertLabel(a),
                    style: AppTypography.body,
                  ),
                  trailing: a == _alert
                      ? const Icon(Icons.check, size: 20, color: AppColors.textPrimary)
                      : null,
                  onTap: () {
                    setState(() => _alert = a);
                    Navigator.pop(ctx);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * AppSizes.sheetMaxHeightFraction,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSheet),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildTitleField(),
              const _SheetDivider(),
              _buildRow(
                label: 'DATE',
                value: DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                icon: Icons.calendar_today_outlined,
                onTap: _pickDate,
              ),
              const _SheetDivider(),
              _buildTimeRow(),
              const _SheetDivider(),
              _buildRow(
                label: 'REPEAT',
                value: _recurrenceLabel(_recurrence),
                icon: Icons.replay_outlined,
                onTap: _pickRecurrence,
              ),
              const _SheetDivider(),
              _buildRow(
                label: 'ALERT',
                value: _alertLabel(_alert),
                icon: Icons.notifications_none_outlined,
                onTap: _pickAlert,
              ),
              const _SheetDivider(),
              _buildDescriptionField(),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// 상단 바: X(닫기) + "NEW SCHEDULE" + ✓(저장)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.xs,
        AppSizes.sm,
        AppSizes.xs,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 22),
            color: AppColors.textPrimary,
            splashRadius: 20,
          ),
          const Spacer(),
          Text(
            'NEW SCHEDULE',
            style: AppTypography.sectionLabel.copyWith(
              letterSpacing: 2.0,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check, size: 22),
            color: AppColors.textPrimary,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  /// 큰 제목 입력 필드 (sheetTitle 스타일, 24px Black)
  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        style: AppTypography.sheetTitle,
        decoration: InputDecoration(
          hintText: 'Event title',
          hintStyle: AppTypography.sheetTitle.copyWith(
            color: AppColors.outlineVariant,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  /// 카드형 행 — 왼쪽 라벨(sectionLabel) + 오른쪽 값 + 아이콘
  Widget _buildRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                label,
                style: AppTypography.sectionLabel,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: AppTypography.body,
              ),
            ),
            Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// TIME 행 — 시작 시간 / 종료 시간
  Widget _buildTimeRow() {
    final startLabel = DateFormat('h:mm a').format(_startTime);
    final endLabel = DateFormat('h:mm a').format(_endTime);

    return InkWell(
      onTap: () => _pickTime(isStart: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                'TIME',
                style: AppTypography.sectionLabel,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickTime(isStart: true),
                    child: Text(startLabel, style: AppTypography.body),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                    child: Text(
                      '—',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _pickTime(isStart: false),
                    child: Text(endLabel, style: AppTypography.body),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// DESCRIPTION & NOTES 영역
  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESCRIPTION & NOTES',
            style: AppTypography.sectionLabel,
          ),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: _descriptionController,
            style: AppTypography.body,
            maxLines: 4,
            minLines: 2,
            decoration: InputDecoration(
              hintText: 'Add notes...',
              hintStyle: AppTypography.body.copyWith(
                color: AppColors.outlineVariant,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  // ── Label Helpers ──

  String _recurrenceLabel(RecurrenceType type) {
    return switch (type) {
      RecurrenceType.never => 'Never',
      RecurrenceType.daily => 'Daily',
      RecurrenceType.weekly => 'Weekly',
      RecurrenceType.monthly => 'Monthly',
      RecurrenceType.yearly => 'Yearly',
      RecurrenceType.custom => 'Custom',
    };
  }

  String _alertLabel(AlertType type) {
    return switch (type) {
      AlertType.none => 'None',
      AlertType.fiveMinutes => '5 minutes before',
      AlertType.fifteenMinutes => '15 minutes before',
      AlertType.thirtyMinutes => '30 minutes before',
      AlertType.oneHour => '1 hour before',
      AlertType.oneDay => '1 day before',
    };
  }
}

/// Ghost border 스타일 구분선
class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.divider,
      ),
    );
  }
}
