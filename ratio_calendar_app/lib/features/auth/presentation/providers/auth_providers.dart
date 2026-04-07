import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratio_calendar/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ratio_calendar/features/auth/data/services/migration_service.dart';
import 'package:ratio_calendar/features/auth/domain/entities/user_entity.dart';
import 'package:ratio_calendar/features/event/presentation/providers/event_providers.dart';
import 'package:uuid/uuid.dart';

// ── AuthRemoteDatasource Provider ──

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource();
});

// ── MigrationService Provider ──

final migrationServiceProvider = Provider<MigrationService>((ref) {
  return MigrationService(firestore: FirebaseFirestore.instance);
});

// ── Auth State ──

/// 인증 상태: 미로그인(unauthenticated) / 로그인(authenticated)
///
/// 미로그인 → 로컬 DB (in-memory)
/// 로그인 → Firestore + 로컬 캐시
sealed class AuthState {
  const AuthState();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});
  final UserEntity user;
}

class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
}

// ── Auth Notifier ──

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRemoteDatasource _datasource;
  late final MigrationService _migrationService;
  StreamSubscription<User?>? _authSub;

  @override
  AuthState build() {
    _datasource = ref.read(authRemoteDatasourceProvider);
    _migrationService = ref.read(migrationServiceProvider);

    // Firebase Auth 상태 리스닝 (중복 구독 방지)
    _authSub ??= _datasource.authStateChanges.listen(_onAuthStateChanged);
    ref.onDispose(() {
      _authSub?.cancel();
      _authSub = null;
    });

    // 초기 상태: 현재 사용자 확인
    final currentUser = _datasource.currentUser;
    if (currentUser != null) {
      _loadUserEntity(currentUser);
      return const AuthLoading();
    }
    return const AuthUnauthenticated();
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      state = const AuthUnauthenticated();
    } else {
      _loadUserEntity(firebaseUser);
    }
  }

  Future<void> _loadUserEntity(User firebaseUser) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          try {
            state = AuthAuthenticated(
              user: UserEntity(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? '',
                displayName: data['displayName'] as String?,
                photoUrl: data['photoUrl'] as String?,
                defaultWorkspaceId:
                    (data['defaultWorkspaceId'] as String?) ?? 'default',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              ),
            );
          } catch (e) {
            state = AuthError(message: 'Failed to load user data: $e');
          }
        }
      } else {
        // 신규 사용자 — Firestore 문서 + 워크스페이스 생성
        await _createNewUser(firebaseUser);
      }
    } catch (e) {
      state = AuthError(message: e.toString());
    }
  }

  Future<void> _createNewUser(User firebaseUser) async {
    final workspaceId = const Uuid().v4();
    final now = DateTime.now();

    final user = UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      defaultWorkspaceId: workspaceId,
      createdAt: now,
    );

    // Firestore에 사용자 문서 생성
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .set({
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'defaultWorkspaceId': workspaceId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 워크스페이스 + 기본 캘린더 3개 생성
    await _migrationService.createDefaultWorkspace(
      workspaceId: workspaceId,
      userId: firebaseUser.uid,
    );

    // 로컬 이벤트 → Firestore 마이그레이션
    final localEvents = ref.read(localEventsProvider).valueOrNull ?? [];
    if (localEvents.isNotEmpty) {
      await _migrationService.migrateLocalEvents(
        workspaceId: workspaceId,
        events: localEvents,
      );
      // 마이그레이션 후 로컬 이벤트는 Firestore 동기화 시 갱신됨
      ref.invalidate(localEventsProvider);
    }

    state = AuthAuthenticated(user: user);
  }

  /// 이메일 + 비밀번호 로그인
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      await _datasource.signInWithEmail(email: email, password: password);
      // authStateChanges 리스너가 상태 업데이트 처리
    } on FirebaseAuthException catch (e) {
      state = AuthError(message: _mapFirebaseError(e.code));
    }
  }

  /// Google 소셜 로그인
  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final result = await _datasource.signInWithGoogle();
      if (result == null) {
        // 사용자가 Google 로그인 취소
        state = const AuthUnauthenticated();
      }
      // authStateChanges 리스너가 상태 업데이트 처리
    } on FirebaseAuthException catch (e) {
      state = AuthError(message: _mapFirebaseError(e.code));
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _datasource.signOut();
    state = const AuthUnauthenticated();
  }

  String _mapFirebaseError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password.',
      'invalid-email' => 'Invalid email address.',
      'user-disabled' => 'This account has been disabled.',
      'email-already-in-use' => 'An account already exists with this email.',
      'weak-password' => 'Password must be at least 6 characters.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      _ => 'Authentication failed. Please try again.',
    };
  }
}

// ── 편의 Provider ──

/// 현재 로그인 여부
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});

/// 현재 로그인된 사용자 (nullable)
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) return authState.user;
  return null;
});
