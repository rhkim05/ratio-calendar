import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Auth 원격 데이터소스
///
/// 이메일/비밀번호 + Google 소셜 로그인 지원
class AuthRemoteDatasource {
  AuthRemoteDatasource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// 현재 로그인된 사용자
  User? get currentUser => _firebaseAuth.currentUser;

  /// 인증 상태 스트림
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// 이메일 + 비밀번호 로그인
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 이메일 + 비밀번호 회원가입
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Google 소셜 로그인
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // 사용자가 취소

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  /// 로그아웃
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
