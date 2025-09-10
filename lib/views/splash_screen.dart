import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADD THIS IMPORT
import 'package:finance_tracker/providers/auth_provider.dart';
import 'package:finance_tracker/screens/dashboard.dart';
import 'package:finance_tracker/views/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  void _navigateBasedOnAuth(User? user, BuildContext context) {
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (user != null) {
      // User is logged in, go to Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      // No user is logged in, go to LoginScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the authStateProvider. This will rebuild the widget when the auth state changes.
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Show a loading indicator while checking the initial auth state
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      // If an error occurs (e.g., no internet connection)
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
      // When the authentication state is known
      data: (user) {
        // Use a small delay to allow the splash screen to be visible
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateBasedOnAuth(user, context);
        });

        // Show a simple splash screen while deciding where to navigate
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
