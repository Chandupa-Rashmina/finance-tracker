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
      print('AuthRepository: Creating user with email: $email');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('AuthRepository: User created: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('AuthRepository: Firebase Error - ${e.code}: ${e.message}');
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      print('AuthRepository: Unexpected error during signup: $e');
      
      // WORKAROUND: Check if user was actually created despite the error
      // This handles the 'PigeonUserDetails' plugin bug
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        print('AuthRepository: User was created despite plugin error: ${currentUser.email}');
        return currentUser;
      }
      
      // If no user was created, re-throw as a FirebaseAuthException
      throw FirebaseAuthException(
        code: 'unknown-error', 
        message: 'Registration failed due to an unexpected error'
      );
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
    } catch (e) {
      print('AuthRepository: Unexpected error during signin: $e');
      
      // WORKAROUND: Check if user was actually logged in despite the error
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        print('AuthRepository: User was logged in despite plugin error: ${currentUser.email}');
        return currentUser;
      }
      
      throw FirebaseAuthException(
        code: 'unknown-error', 
        message: 'Login failed due to an unexpected error'
      );
    }
  }

  // Sign out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}