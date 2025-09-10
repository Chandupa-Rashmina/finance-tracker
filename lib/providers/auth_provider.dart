import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

// This provider gives us access to the AuthRepository instance throughout the app.
// It is "final" because we don't need to change the repository itself.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// This is the most important provider.
// It listens to the authStateChanges stream from AuthRepository.
// The stream will emit a User? object (a Firebase user) when the login state changes.
// It emits null if no user is logged in, and a User object if a user is logged in.
final authStateProvider = StreamProvider<User?>((ref) {
  // Watch the authRepositoryProvider to get the AuthRepository instance
  final authRepository = ref.watch(authRepositoryProvider);
  // Return the authStateChanges stream from the repository
  return authRepository.authStateChanges;
});
