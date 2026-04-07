import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/constants/enums.dart';
import 'package:ratio_calendar/core/router/app_router.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:ratio_calendar/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:ratio_calendar/features/workspace/presentation/providers/workspace_providers.dart';

/// 사이드 메뉴 — 좌측 Drawer
class SideMenuScreen extends ConsumerWidget {
  const SideMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentView = ref.watch(currentViewTypeProvider);
    final calendarsAsync = ref.watch(calendarListProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final user = ref.watch(currentUserProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);

    return Drawer(
      width: AppSizes.sideMenuWidth,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 프로필 헤더 + 워크스페이스 드롭다운 ──
            InkWell(
              onTap: isLoggedIn
                  ? () => _showWorkspacePicker(context, ref)
                  : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, AppSizes.lg, AppSizes.md, AppSizes.lg,
                ),
                child: Row(
                  children: [
                    // 아바타
                    Container(
                      width: AppSizes.avatarMedium,
                      height: AppSizes.avatarMedium,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighest,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  currentWorkspace?.name ?? 'My Workspace',
                                  style: AppTypography.eventTitle.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isLoggedIn) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'Local Mode',
                            style: AppTypography.eventTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 뷰 전환 옵션 ──
            _ViewOption(
              icon: Icons.calendar_view_day,
              label: 'DAY',
              isSelected: currentView == CalendarViewType.day,
              onTap: () {
                ref
                    .read(currentViewTypeProvider.notifier)
                    .change(CalendarViewType.day);
                Navigator.of(context).pop();
              },
            ),
            _ViewOption(
              icon: Icons.calendar_view_week,
              label: '3-DAY',
              isSelected: currentView == CalendarViewType.threeDay,
              onTap: () {
                ref
                    .read(currentViewTypeProvider.notifier)
                    .change(CalendarViewType.threeDay);
                Navigator.of(context).pop();
              },
            ),
            _ViewOption(
              icon: Icons.calendar_month,
              label: 'MONTH',
              isSelected: currentView == CalendarViewType.month,
              onTap: () {
                ref
                    .read(currentViewTypeProvider.notifier)
                    .change(CalendarViewType.month);
                Navigator.of(context).pop();
              },
            ),

            const SizedBox(height: AppSizes.lg),

            // ── CALENDARS 섹션 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text(
                'CALENDARS',
                style: AppTypography.sectionLabel,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            calendarsAsync.when(
              data: (calendars) => Column(
                children: calendars.map((cal) {
                  final color = _parseColor(cal.colorHex);
                  return _CalendarItem(
                    color: color,
                    label: cal.name,
                    isEnabled: cal.isVisible,
                    onTap: () {
                      ref
                          .read(calendarListProvider.notifier)
                          .toggleVisibility(cal.id);
                    },
                  );
                }).toList(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const Spacer(),

            // ── SETTINGS ──
            Divider(
              color: AppColors.divider,
              height: 1,
            ),
            _ViewOption(
              icon: Icons.settings_outlined,
              label: 'SETTINGS',
              isSelected: false,
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.settings);
              },
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }

  void _showWorkspacePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSheet),
        ),
      ),
      builder: (_) => _WorkspacePickerSheet(),
    );
  }

  Color _parseColor(String hex) {
    final value = int.tryParse(
      'FF${hex.replaceFirst('#', '')}',
      radix: 16,
    );
    return Color(value ?? 0xFF007AFF);
  }
}

// ── Workspace Picker Bottom Sheet ──

class _WorkspacePickerSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_WorkspacePickerSheet> createState() =>
      _WorkspacePickerSheetState();
}

class _WorkspacePickerSheetState
    extends ConsumerState<_WorkspacePickerSheet> {
  bool _isCreating = false;
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(workspaceListProvider);
    final currentId = ref.watch(currentWorkspaceIdProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.md,
              ),
              child: Text('WORKSPACES', style: AppTypography.headline),
            ),

            // 워크스페이스 목록
            workspacesAsync.when(
              data: (workspaces) => Column(
                children: workspaces.map((ws) {
                  final isSelected = ws.id == currentId;
                  return InkWell(
                    onTap: () {
                      ref
                          .read(currentWorkspaceIdProvider.notifier)
                          .select(ws.id);
                      // 캘린더 목록 새로고침
                      ref.invalidate(calendarListProvider);
                      Navigator.of(context).pop();
                      // Drawer도 닫기
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ws.name,
                              style: AppTypography.body.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // 구분선
            Divider(
              color: AppColors.divider,
              height: 1,
              indent: AppSizes.md,
              endIndent: AppSizes.md,
            ),

            // New Workspace 버튼 또는 입력 필드
            if (_isCreating)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        style: AppTypography.body,
                        decoration: InputDecoration(
                          hintText: 'Workspace name',
                          hintStyle: AppTypography.body.copyWith(
                            color: AppColors.outlineVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _createWorkspace(),
                      ),
                    ),
                    IconButton(
                      onPressed: _createWorkspace,
                      icon: const Icon(Icons.check, size: 20),
                      color: AppColors.textPrimary,
                      splashRadius: 20,
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isCreating = false),
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondary,
                      splashRadius: 20,
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: () {
                  setState(() => _isCreating = true);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _focusNode.requestFocus();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add,
                        size: 20,
                        color: AppColors.personal,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'New Workspace',
                        style: AppTypography.body.copyWith(
                          color: AppColors.personal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Future<void> _createWorkspace() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await ref.read(workspaceListProvider.notifier).createWorkspace(name);

    if (mounted) {
      Navigator.of(context).pop(); // 시트 닫기
      Navigator.of(context).pop(); // Drawer 닫기
    }
  }
}

// ── Private Widgets ──

class _ViewOption extends StatelessWidget {
  const _ViewOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        color: isSelected ? AppColors.surface : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.sm + AppSizes.xs),
            Text(
              label,
              style: AppTypography.dayLabel.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarItem extends StatelessWidget {
  const _CalendarItem({
    required this.color,
    required this.label,
    required this.isEnabled,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.calendarDotSize,
              height: AppSizes.calendarDotSize,
              decoration: BoxDecoration(
                color: isEnabled ? color : AppColors.outlineVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.sm + AppSizes.xs),
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
