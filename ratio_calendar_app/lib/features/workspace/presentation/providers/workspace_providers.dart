import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:ratio_calendar/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:ratio_calendar/features/workspace/domain/entities/workspace_entity.dart';
import 'package:uuid/uuid.dart';

// ── Repository Provider ──

/// main.dart에서 override로 주입
final workspaceRepositoryProvider =
    Provider<WorkspaceRepositoryImpl>((ref) {
  throw UnimplementedError('workspaceRepositoryProvider must be overridden');
});

// ── 워크스페이스 목록 ──

final workspaceListProvider =
    AsyncNotifierProvider<WorkspaceListNotifier, List<WorkspaceEntity>>(
  WorkspaceListNotifier.new,
);

class WorkspaceListNotifier extends AsyncNotifier<List<WorkspaceEntity>> {
  @override
  Future<List<WorkspaceEntity>> build() async {
    final repo = ref.watch(workspaceRepositoryProvider);
    final user = ref.watch(currentUserProvider);

    if (user != null) {
      // 로그인 상태: Firestore에서 동기화
      try {
        final synced = await repo.syncWorkspacesFromFirestore(user.id);
        if (synced.isNotEmpty) return synced;
      } catch (e) {
        // 네트워크 에러 시 로컬 데이터로 fallback
        debugPrint('Workspace sync failed: $e');
      }
    }

    // 미로그인 또는 Firestore 워크스페이스 없음
    await repo.ensureDefaultWorkspace();
    return repo.getAllWorkspaces();
  }

  Future<WorkspaceEntity> createWorkspace(String name) async {
    final repo = ref.read(workspaceRepositoryProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) {
      throw StateError('Login required to create workspace');
    }

    final id = const Uuid().v4();
    final workspace = await repo.createWorkspaceOnFirestore(
      id: id,
      name: name,
      userId: user.id,
    );

    state = AsyncValue.data(<WorkspaceEntity>[
      ...(state.valueOrNull ?? []),
      workspace,
    ]);

    return workspace;
  }
}

// ── 현재 선택된 워크스페이스 ──

final currentWorkspaceIdProvider =
    NotifierProvider<CurrentWorkspaceIdNotifier, String>(
  CurrentWorkspaceIdNotifier.new,
);

class CurrentWorkspaceIdNotifier extends Notifier<String> {
  @override
  String build() {
    final user = ref.watch(currentUserProvider);
    return user?.defaultWorkspaceId ?? 'local';
  }

  void select(String workspaceId) {
    state = workspaceId;
  }
}

/// 현재 워크스페이스 엔티티 (편의 Provider)
final currentWorkspaceProvider = Provider<WorkspaceEntity?>((ref) {
  final id = ref.watch(currentWorkspaceIdProvider);
  final workspaces = ref.watch(workspaceListProvider).valueOrNull ?? [];
  if (workspaces.isEmpty) return null;
  return workspaces.where((w) => w.id == id).firstOrNull ??
      workspaces.first;
});
