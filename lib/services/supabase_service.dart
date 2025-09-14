import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  /// Initialize Supabase service (use after Supabase.initialize() has been called)
  static void initialize() {
    instance._client = Supabase.instance.client;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucketName,
    required String fileName,
    required Uint8List fileBytes,
    String? mimeType,
  }) async {
    await _client.storage.from(bucketName).uploadBinary(
      fileName,
      fileBytes,
      fileOptions: FileOptions(
        contentType: mimeType,
      ),
    );

    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    await _client.storage.from(bucketName).remove([fileName]);
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}