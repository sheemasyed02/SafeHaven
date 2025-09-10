import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => client.auth.currentUser != null;

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting signup for: $email'); // Debug logging
      final response = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Don't redirect after email confirmation
      );
      
      print('Signup response: ${response.user?.id}'); // Debug logging
      print('Email confirmed: ${response.user?.emailConfirmedAt != null}'); // Debug logging
      
      if (response.user != null && response.user!.emailConfirmedAt == null) {
        print('⚠️ Email confirmation required. User created but not confirmed.');
        print('Check your email for confirmation link.');
      }
      
      return response;
    } catch (e) {
      print('Supabase signup error: $e'); // Debug logging
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting signin for: $email'); // Debug logging
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('Signin response: ${response.user?.id}'); // Debug logging
      return response;
    } catch (e) {
      print('Supabase signin error: $e'); // Debug logging
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
