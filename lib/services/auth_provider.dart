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
          providerType: userProfile?['provider_type'],
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
        // Check if email confirmation is required
        final needsConfirmation = response.user!.emailConfirmedAt == null;
        
        if (!needsConfirmation) {
          // Email is already confirmed or confirmation is disabled
          // Create user profile in users table without role
          await _supabaseService.client
            .from('users')
            .upsert({
              'id': response.user!.id,
              'email': response.user!.email,
              'name': response.user!.email?.split('@')[0] ?? 'User', // Use email prefix as default name
              'created_at': response.user!.createdAt,
              // Note: role is intentionally not set - will be set during role selection
            });
          
          final user = User(
            id: response.user!.id,
            email: response.user!.email ?? '',
            name: response.user!.email?.split('@')[0] ?? 'User',
            createdAt: DateTime.parse(response.user!.createdAt),
            // role is null initially
          );
          state = state.copyWith(user: user, isLoading: false);
        } else {
          // Email confirmation is required
          state = state.copyWith(
            isLoading: false,
            error: 'Please check your email and click the confirmation link to continue.',
          );
        }
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

  /// Update user role in Supabase users table
  Future<void> updateUserRole(String role, {String? providerType}) async {
    final user = state.user;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    try {
      print('🔄 Starting role update: role=$role, providerType=$providerType'); // Debug
      
      // First, check if user exists in users table
      final existingUser = await _supabaseService.client
        .from('users')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();
      
      print('📊 Existing user data: $existingUser'); // Debug
      
      // Prepare update data
      final Map<String, dynamic> updates = {
        'role': role,
      };
      
      if (providerType != null) {
        updates['provider_type'] = providerType;
      }
      
      print('📝 Update data: $updates'); // Debug
      
      // If user doesn't exist, create them first
      if (existingUser == null) {
        print('👤 Creating new user record...'); // Debug
        final createData = {
          'id': user.id,
          'email': user.email,
          'name': user.email.split('@')[0], // Use email prefix as default name
          'created_at': DateTime.now().toIso8601String(),
          ...updates,
        };
        
        final createResponse = await _supabaseService.client
          .from('users')
          .insert(createData)
          .select();
          
        print('✅ User created: $createResponse'); // Debug
      } else {
        // Update existing user
        print('🔄 Updating existing user...'); // Debug
        final updateResponse = await _supabaseService.client
          .from('users')
          .update(updates)
          .eq('id', user.id)
          .select();
          
        print('✅ User updated: $updateResponse'); // Debug
        
        if (updateResponse.isEmpty) {
          throw Exception('Update failed - no rows affected');
        }
      }
      
      // Update local state with new role and provider type
      state = state.copyWith(
        user: user.copyWith(
          role: role,
          providerType: providerType ?? user.providerType,
        ),
      );
      
      print('🎉 Role updated successfully in local state'); // Debug
    } catch (e) {
      print('❌ UpdateUserRole Error: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      
      // Provide more specific error messages
      String errorMessage = 'Failed to update role';
      if (e.toString().contains('column') && e.toString().contains('does not exist')) {
        errorMessage = 'Database column missing. Please check DATABASE_DIAGNOSTIC.md for setup instructions.';
      } else if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
        errorMessage = 'Database permission denied. This is a Row Level Security (RLS) policy issue. Please check RLS_POLICY_FIX.md for the complete solution.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please check database policies in RLS_POLICY_FIX.md.';
      } else {
        errorMessage = 'Failed to update role: ${e.toString()}';
      }
      
      throw Exception(errorMessage);
    }
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
