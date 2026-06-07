import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Stream of auth state changes ──
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Current user ──
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;
  static String? get userId => _auth.currentUser?.uid;
  static String? get userEmail => _auth.currentUser?.email;
  static String? get displayName => _auth.currentUser?.displayName;

  // ── Sign up with email & password ──
  static Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Sign in with email & password ──
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Sign out ──
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Delete account ──
  static Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
