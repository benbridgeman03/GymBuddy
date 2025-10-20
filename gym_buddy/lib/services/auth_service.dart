import 'package:firebase_auth/firebase_auth.dart';
import 'seed_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign up new user
  Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;

    // Send verification email
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();

      // Seed default exercises for this user
      await seedDefaultExercises(user.uid);
    }

    return user;
  }

  /// Send email verification to user
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Sign in existing user
  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream for current user changes (login/logout)
  Stream<User?> get userStream => _auth.authStateChanges();
}
