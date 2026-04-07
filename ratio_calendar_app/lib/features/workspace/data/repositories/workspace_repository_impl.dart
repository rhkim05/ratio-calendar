import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ratio_calendar/features/workspace/data/datasources/workspace_local_datasource.dart';
import 'package:ratio_calendar/features/workspace/domain/entities/workspace_entity.dart';

/// 워크스페이스 Repository
///
/// 미로그인: 로컬 'local' 워크스페이스만 사용
/// 로그인: Firestore에서 워크스페이스 목록 로드 + 로컬 캐시
class WorkspaceRepositoryImpl {
  WorkspaceRepositoryImpl({required this.localDataSource});

  final WorkspaceLocalDataSource localDataSource;

  /// 로컬 워크스페이스 목록 조회
  Future<List<WorkspaceEntity>> getAllWorkspaces() {
    return localDataSource.getAllWorkspaces();
  }

  /// 로컬 워크스페이스 저장
  Future<void> saveWorkspace(WorkspaceEntity workspace) {
    return localDataSource.saveWorkspace(workspace);
  }

  /// 기본 로컬 워크스페이스 보장
  Future<void> ensureDefaultWorkspace() async {
    final existing = await localDataSource.getAllWorkspaces();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    await localDataSource.saveWorkspace(
      WorkspaceEntity(
        id: 'local',
        name: 'My Workspace',
        ownerId: 'local',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Firestore에 워크스페이스 생성
  Future<WorkspaceEntity> createWorkspaceOnFirestore({
    required String id,
    required String name,
    required String userId,
  }) async {
    final now = DateTime.now();

    await FirebaseFirestore.instance
        .collection('workspaces')
        .doc(id)
        .set({
      'name': name,
      'ownerId': userId,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 기본 캘린더 3개 생성
    final batch = FirebaseFirestore.instance.batch();
    final wsRef = FirebaseFirestore.instance.collection('workspaces').doc(id);
    for (final cal in _defaultCalendars) {
      final calRef = wsRef.collection('calendars').doc();
      batch.set(calRef, {
        'name': cal['name'],
        'colorHex': cal['colorHex'],
        'isVisible': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    final workspace = WorkspaceEntity(
      id: id,
      name: name,
      ownerId: userId,
      members: [userId],
      createdAt: now,
      updatedAt: now,
    );

    // 로컬에도 캐시
    await localDataSource.saveWorkspace(workspace);

    return workspace;
  }

  /// Firestore에서 사용자의 모든 워크스페이스 로드 → 로컬 캐시
  Future<List<WorkspaceEntity>> syncWorkspacesFromFirestore(
    String userId,
  ) async {
    final snap = await FirebaseFirestore.instance
        .collection('workspaces')
        .where('members', arrayContains: userId)
        .get();

    final workspaces = <WorkspaceEntity>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final ws = WorkspaceEntity(
        id: doc.id,
        name: data['name'] as String? ?? 'Workspace',
        ownerId: data['ownerId'] as String? ?? '',
        members: (data['members'] as List?)?.cast<String>() ?? [],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
      workspaces.add(ws);
      await localDataSource.saveWorkspace(ws);
    }

    return workspaces;
  }

  static const _defaultCalendars = [
    {'name': 'Personal', 'colorHex': '#007AFF'},
    {'name': 'Work', 'colorHex': '#FF3B30'},
    {'name': 'Shared', 'colorHex': '#34C759'},
  ];
}
