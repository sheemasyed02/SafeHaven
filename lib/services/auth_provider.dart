import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  final _supabaseService = SupabaseService.instance;

  /// Check current authentication status
  void _checkAuthStatus() {
    final currentUser = _supabaseService.currentUser;
    if (currentUser != null) {
      // Convert Supabase User to your User model
      final user = User(
        id: currentUser.id,
        email: currentUser.email ?? '',
        createdAt: DateTime.parse(currentUser.createdAt),
      );
      state = state.copyWith(user: user);
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          createdAt: DateTime.parse(response.user!.createdAt),
        );
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed: No user returned',
        );
      }
    } catch (e) {
      print('SignIn Error: $e'); // Add debug logging
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow; // Re-throw for UI handling
    }
  }

  /// Sign up with email and password
  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          createdAt: DateTime.parse(response.user!.createdAt),
        );
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Signup failed: No user returned',
        );
      }
    } catch (e) {
      print('SignUp Error: $e'); // Add debug logging
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow; // Re-throw for UI handling
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _supabaseService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
