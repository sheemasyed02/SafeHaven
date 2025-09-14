import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

// Providers for auth state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState.user == null) return null;
  
  try {
    return await SupabaseService.instance.getCurrentUserProfile();
  } catch (e) {
    return null;
  }
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState()) {
    _initialize();
  }

  void _initialize() {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;

      switch (event) {
        case AuthChangeEvent.signedIn:
          state = state.copyWith(user: user, isLoading: false, error: null);
          break;
        case AuthChangeEvent.signedOut:
          state = state.copyWith(user: null, isLoading: false, error: null);
          break;
        case AuthChangeEvent.tokenRefreshed:
          state = state.copyWith(user: user, error: null);
          break;
        case AuthChangeEvent.userUpdated:
          state = state.copyWith(user: user, error: null);
          break;
        default:
          break;
      }
    });

    // Check if user is already signed in
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      state = state.copyWith(user: currentUser);
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(
          user: response.user,
          isLoading: false,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<UserProfile> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    print('AuthProvider: Starting signup process');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Sign up the user
      print('AuthProvider: Calling Supabase auth signup');
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      print('AuthProvider: Supabase signup response - User: ${response.user?.id}, Session: ${response.session?.accessToken != null}');

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      // Create user profile
      print('AuthProvider: Creating user profile');
      await SupabaseService.instance.createUserProfile(
        userId: response.user!.id,
        name: name,
        email: email,
        role: role,
        phone: phone,
      );

      // Get the created profile
      print('AuthProvider: Fetching created profile');
      final profile = await SupabaseService.instance.getCurrentUserProfile();
      if (profile == null) {
        throw Exception('Failed to retrieve created profile');
      }

      print('AuthProvider: Profile created successfully - Name: ${profile.name}, Role: ${profile.role}');

      state = state.copyWith(
        user: response.user,
        isLoading: false,
        error: null,
      );

      return profile;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Supabase.instance.client.auth.signOut();
      state = state.copyWith(
        user: null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://safehaven.com/reset-password',
      );
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    if (state.user == null) return null;

    try {
      return await SupabaseService.instance.getCurrentUserProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await SupabaseService.instance.updateUserProfile(
        userId: profile.id,
        name: profile.name,
        phone: profile.phone,
        avatarUrl: profile.avatarUrl,
      );
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Helper provider to get user role
final userRoleProvider = FutureProvider<UserRole?>((ref) async {
  final profile = await ref.watch(currentUserProfileProvider.future);
  return profile?.role;
});

// Helper provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user != null;
});

// Helper provider to check if user has specific role
Provider<bool> hasRoleProvider(UserRole role) {
  return Provider<bool>((ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    return profileAsync.when(
      data: (profile) => profile?.role == role,
      loading: () => false,
      error: (_, __) => false,
    );
  });
}

// Convenience providers for role checks
final isCustomerProvider = hasRoleProvider(UserRole.customer);
final isProviderProvider = hasRoleProvider(UserRole.provider);