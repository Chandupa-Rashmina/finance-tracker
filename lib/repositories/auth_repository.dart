import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // Constructor. Allows for dependency injection (useful for testing).
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Stream that emits the current User whenever the authentication state changes.
  // This allows the UI to react to login/logout instantly.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get the currently logged-in user. Returns null if not logged in.
  User? get currentUser => _firebaseAuth.currentUser;

  // Create a new user with an email and password.
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      print('AuthRepository: Creating user with email: $email'); // DEBUG PRINT
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(
          'AuthRepository: User created: ${userCredential.user?.email}'); // DEBUG PRINT
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('AuthRepository: Error - ${e.code}: ${e.message}'); // DEBUG PRINT
      // Re-throw the exception so the UI can handle it (e.g., show an error message).
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Sign in an existing user with an email and password.
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Sign out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
