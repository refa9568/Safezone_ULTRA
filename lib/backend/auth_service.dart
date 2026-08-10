import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firebase Authentication. Firebase stores and hashes
/// the password itself — this app never sees or persists a raw password.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  /// Sends a password reset link to this email. Firebase handles the reset
  /// page and updates the account's password directly - the app never sees
  /// the new password.
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Permanently deletes the signed-in Firebase Auth account. Call this
  /// alongside AppState.deleteAllData() (Firestore) to fully remove a user.
  /// Firebase requires a recent sign-in for this - if it's been a while,
  /// this throws 'requires-recent-login' (see [friendlyError]).
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Sends a verification link to the currently signed-in user's email.
  /// Call right after [signUp] — no-op if already verified.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Refreshes the current user from Firebase and reports whether their
  /// email is verified now. Firestore data must not be written until this
  /// returns true.
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Turns a FirebaseAuthException into a message safe to show a parent.
  String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address looks invalid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Choose a stronger password (6+ characters).';
        case 'network-request-failed':
          return 'No internet connection. Try again.';
        case 'requires-recent-login':
          return 'For security, please log out and log back in, then try again.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
