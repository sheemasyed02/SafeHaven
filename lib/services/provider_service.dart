import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/provider_profile.dart';
import 'supabase_service.dart';

class ProviderService {
  static ProviderService? _instance;
  static ProviderService get instance => _instance ??= ProviderService._();

  ProviderService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Create provider profile with ID upload
  Future<void> createProviderProfile({
    required String userId,
    required String bio,
    required List<String> skills,
    required List<String> categories,
    required File idImage,
  }) async {
    try {
      // Upload ID image to Supabase Storage
      final String fileName = 'provider_id_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String idImageUrl = await _uploadIdImage(idImage, fileName);

      // Create provider profile in database
      await _client.from('providers').insert({
        'user_id': userId,
        'bio': bio,
        'skills': skills,
        'categories': categories,
        'id_image_url': idImageUrl,
        'verification_status': 'pending', // Will be verified by admin
        'is_active': false, // Inactive until verified
        'created_at': DateTime.now().toIso8601String(),
      });

      print('Provider profile created successfully');
    } catch (e) {
      print('Error creating provider profile: $e');
      rethrow;
    }
  }

  /// Upload ID image to Supabase Storage
  Future<String> _uploadIdImage(File image, String fileName) async {
    try {
      // Upload to provider_ids bucket
      await _client.storage
          .from('provider_ids')
          .upload(fileName, image);

      // Get public URL
      final String publicUrl = _client.storage
          .from('provider_ids')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading ID image: $e');
      throw Exception('Failed to upload ID image: $e');
    }
  }

  /// Get provider profile by user ID
  Future<ProviderProfile?> getProviderProfile(String userId) async {
    try {
      final response = await _client
          .from('providers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return ProviderProfile.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting provider profile: $e');
      rethrow;
    }
  }

  /// Update provider profile
  Future<void> updateProviderProfile({
    required String userId,
    String? bio,
    List<String>? skills,
    List<String>? categories,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (bio != null) updates['bio'] = bio;
      if (skills != null) updates['skills'] = skills;
      if (categories != null) updates['categories'] = categories;
      if (isActive != null) updates['is_active'] = isActive;

      await _client
          .from('providers')
          .update(updates)
          .eq('user_id', userId);

      print('Provider profile updated successfully');
    } catch (e) {
      print('Error updating provider profile: $e');
      rethrow;
    }
  }

  /// Get all verified providers
  Future<List<ProviderProfile>> getVerifiedProviders() async {
    try {
      final response = await _client
          .from('providers')
          .select()
          .eq('verification_status', 'verified')
          .eq('is_active', true);

      return response.map((json) => ProviderProfile.fromJson(json)).toList();
    } catch (e) {
      print('Error getting verified providers: $e');
      rethrow;
    }
  }

  /// Get providers by category
  Future<List<ProviderProfile>> getProvidersByCategory(String category) async {
    try {
      final response = await _client
          .from('providers')
          .select()
          .contains('categories', [category])
          .eq('verification_status', 'verified')
          .eq('is_active', true);

      return response.map((json) => ProviderProfile.fromJson(json)).toList();
    } catch (e) {
      print('Error getting providers by category: $e');
      rethrow;
    }
  }
}

/// Provider service provider for Riverpod
final providerServiceProvider = Provider<ProviderService>((ref) {
  return ProviderService.instance;
});
