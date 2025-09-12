import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_provider.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show loading while checking auth state
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If user is not authenticated, show login
    if (authState.user == null) {
      return const LoginScreen();
    }

    // If user is authenticated but has no role, show role selection
    if (authState.user!.role == null || authState.user!.role!.isEmpty) {
      return const RoleSelectionScreen();
    }

    // User is authenticated and has a role, show home screen
    return const HomeScreen();
  }
}
