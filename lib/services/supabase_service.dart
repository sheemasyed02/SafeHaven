import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/user_profile.dart';

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

  /// Sign up with email and password and create profile
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role.value,
        'phone': phone,
      },
    );

    // If signup is successful and user is confirmed, create profile
    if (response.user != null) {
      await createUserProfile(
        userId: response.user!.id,
        name: name,
        email: email,
        role: role,
        phone: phone,
      );
    }

    return response;
  }

  /// Create user profile in profiles table
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required UserRole role,
    String? phone,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    await _client.from('profiles').insert({
      'id': userId,
      'name': name,
      'email': email,
      'role': role.value,
      'current_mode': role.value, // Set currentMode to the selected role
      'can_switch_roles': true, // Enable role switching by default
      'phone': phone,
      'created_at': now,
      'updated_at': now,
    });
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    
    return await getUserProfile(user.id);
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId);
  }

  /// Get all providers
  Future<List<UserProfile>> getProviders() async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('role', 'provider')
          .order('created_at', ascending: false);

      return response.map<UserProfile>((data) => UserProfile.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching providers: $e');
      return [];
    }
  }

  /// Search providers by name or services
  Future<List<UserProfile>> searchProviders({
    String? searchQuery,
    List<String>? serviceCategories,
  }) async {
    try {
      var query = _client
          .from('profiles')
          .select()
          .eq('role', 'provider');

      // Add text search if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,bio.ilike.%$searchQuery%');
      }

      // Add service category filter if provided
      if (serviceCategories != null && serviceCategories.isNotEmpty) {
        // Using overlap operator to check if any of the services match
        query = query.overlaps('services', serviceCategories);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map<UserProfile>((data) => UserProfile.fromJson(data)).toList();
    } catch (e) {
      print('Error searching providers: $e');
      return [];
    }
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