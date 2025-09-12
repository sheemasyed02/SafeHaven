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
  /// Update user role in Supabase users table
  Future<void> updateUserRole(String role) async {
    final user = state.user;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    try {
      final response = await _supabaseService.client
        .from('users')
        .update({'role': role})
        .eq('id', user.id)
        .select();
      if (response.isEmpty) {
        throw Exception('Failed to update role');
      }
      // Update local state with new role
      state = state.copyWith(user: user.copyWith(role: role));
    } catch (e) {
      print('UpdateUserRole Error: $e');
      throw Exception('Failed to update role: $e');
    }
  }
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
        // Fetch user profile with role from users table
        final userProfile = await _supabaseService.client
          .from('users')
          .select('*')
          .eq('id', response.user!.id)
          .maybeSingle();
        
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          firstName: userProfile?['first_name'],
          lastName: userProfile?['last_name'],
          phoneNumber: userProfile?['phone_number'],
          role: userProfile?['role'],
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
        // Create user profile in users table without role
        await _supabaseService.client
          .from('users')
          .upsert({
            'id': response.user!.id,
            'email': response.user!.email,
            'created_at': response.user!.createdAt,
            // Note: role is intentionally not set - will be set during role selection
          });
        
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          createdAt: DateTime.parse(response.user!.createdAt),
          // role is null initially
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
