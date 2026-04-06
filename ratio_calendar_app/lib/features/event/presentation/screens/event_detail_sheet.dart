import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';
import 'package:ratio_calendar/features/event/presentation/providers/event_providers.dart';
import 'package:ratio_calendar/features/event/presentation/screens/event_create_sheet.dart';
import 'package:ratio_calendar/shared/widgets/attendee_avatar.dart';

/// 일정 상세 Bottom Sheet
///
/// 캘린더에서 이벤트 블록 탭 시 아래에서 올라옴.
/// 편집 아이콘 → EventCreateSheet(편집 모드)로 전환.
/// 삭제 → 확인 다이얼로그 후 삭제.
class EventDetailSheet extends ConsumerWidget {
  const EventDetailSheet({
    super.key,
    required this.event,
    required this.calendarColor,
    this.calendarName,
  });

  final EventEntity event;
  final Color calendarColor;
  final String? calendarName;

  /// Bottom Sheet를 표시하는 헬퍼 메서드
  static Future<void> show(
    BuildContext context, {
    required EventEntity event,
    required Color calendarColor,
    String? calendarName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDetailSheet(
        event: event,
        calendarColor: calendarColor,
        calendarName: calendarName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height * AppSizes.sheetMaxHeightFraction,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            onEdit: () => _onEdit(context, ref),
            onDelete: () => _onDelete(context, ref),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이벤트 제목
                  _TitleSection(title: event.title),

                  // 캘린더 라벨
                  _CalendarLabel(
                    color: calendarColor,
                    name: calendarName ?? _calendarDisplayName(event.calendarId),
                  ),

                  const SizedBox(height: AppSizes.sm),
                  const _SheetDivider(),

                  // DATE
                  _InfoRow(
                    label: 'DATE',
                    value: DateFormat('EEEE, MMM d, yyyy').format(event.date),
                    icon: Icons.calendar_today_outlined,
                  ),
                  const _SheetDivider(),

                  // TIME
                  _InfoRow(
                    label: 'TIME',
                    value:
                        '${DateFormat('h:mm a').format(event.startTime)} — ${DateFormat('h:mm a').format(event.endTime)}',
                    icon: Icons.access_time_outlined,
                  ),
                  const _SheetDivider(),

                  // ALERT
                  _InfoRow(
                    label: 'ALERT',
                    value: _alertLabel(event.alert),
                    icon: Icons.notifications_none_outlined,
                  ),
                  const _SheetDivider(),

                  // PEOPLE
                  if (event.attendees.isNotEmpty) ...[
                    _PeopleRow(attendees: event.attendees),
                    const _SheetDivider(),
                  ],

                  // DESCRIPTION & NOTES
                  if (event.description != null &&
                      event.description!.isNotEmpty)
                    _DescriptionSection(text: event.description!),

                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ),

          // 하단 닫기 버튼
          _CloseButton(onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  void _onEdit(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    EventCreateSheet.show(
      context,
      initialDate: event.date,
      initialStartTime: event.startTime,
    );
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Event', style: AppTypography.headline),
        content: Text(
          'Are you sure you want to delete "${event.title}"?',
          style: AppTypography.body,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        backgroundColor: AppColors.background,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: AppTypography.sectionLabel.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'DELETE',
              style: AppTypography.sectionLabel.copyWith(
                color: AppColors.currentTimeIndicator,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(localEventsProvider.notifier).remove(event.id);
      Navigator.of(context).pop();
    }
  }

  String _calendarDisplayName(String calendarId) {
    return switch (calendarId) {
      'sprint' => 'SPRINT PLANNING',
      'design' => 'DESIGN SYNC',
      'deepwork' => 'DEEP WORK',
      'standup' => 'TEAM STANDUP',
      _ => calendarId.toUpperCase(),
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

// ── Header: 일시정지 + "EVENT DETAILS" + 편집 아이콘 ──

class _Header extends StatelessWidget {
  const _Header({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.textSecondary,
            splashRadius: 20,
          ),
          const Spacer(),
          Text(
            'EVENT DETAILS',
            style: AppTypography.sectionLabel.copyWith(
              letterSpacing: 2.0,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.textSecondary,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ── Title Section ──

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      child: Text(title, style: AppTypography.sheetTitle),
    );
  }
}

// ── Calendar Label: 색상 도트 + 캘린더 이름 ──

class _CalendarLabel extends StatelessWidget {
  const _CalendarLabel({required this.color, required this.name});

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Row(
        children: [
          Container(
            width: AppSizes.calendarDotSize,
            height: AppSizes.calendarDotSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            name,
            style: AppTypography.sectionLabel.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row: 라벨 + 값 + 아이콘 ──

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: AppTypography.sectionLabel),
          ),
          Expanded(
            child: Text(value, style: AppTypography.body),
          ),
          Icon(icon, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// ── People Row ──

class _PeopleRow extends StatelessWidget {
  const _PeopleRow({required this.attendees});

  final List<String> attendees;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text('PEOPLE', style: AppTypography.sectionLabel),
          ),
          Expanded(
            child: AttendeeAvatarRow(names: attendees),
          ),
          Icon(Icons.people_outline, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// ── Description Section ──

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DESCRIPTION & NOTES', style: AppTypography.sectionLabel),
          const SizedBox(height: AppSizes.sm),
          Text(text, style: AppTypography.body),
        ],
      ),
    );
  }
}

// ── Close Button ──

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.md),
        child: Center(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ghost Border Divider ──

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
