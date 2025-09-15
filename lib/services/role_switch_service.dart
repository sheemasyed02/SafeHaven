import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

/// Service for managing user role switching
class RoleSwitchService {
  static final instance = RoleSwitchService._();
  RoleSwitchService._();

  /// Switch user's current mode and update in database
  Future<UserProfile?> switchToRole(UserRole newRole) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Update current_mode in database
      await Supabase.instance.client
          .from('profiles')
          .update({'current_mode': newRole.value})
          .eq('id', user.id);

      // Fetch updated profile
      final updatedProfile = await SupabaseService.instance.getCurrentUserProfile();
      return updatedProfile;
    } catch (e) {
      print('Error switching role: $e');
      rethrow;
    }
  }

  /// Check if user can switch to a specific role
  Future<bool> canSwitchToRole(UserRole targetRole) async {
    try {
      final profile = await SupabaseService.instance.getCurrentUserProfile();
      if (profile == null) return false;

      // Users can always switch to customer mode
      if (targetRole == UserRole.customer) return true;

      // For provider mode, check if user has provider capabilities
      if (targetRole == UserRole.provider) {
        // If user's base role is provider, they can switch
        // Or if they have dual roles enabled (canSwitchRoles)
        return profile.role == UserRole.provider || profile.canSwitchRoles;
      }

      return false;
    } catch (e) {
      print('Error checking role switch capability: $e');
      return false;
    }
  }
}

/// Provider for role switching service
final roleSwitchServiceProvider = Provider<RoleSwitchService>((ref) {
  return RoleSwitchService.instance;
});

/// Provider for current user mode (separate from auth state)
final currentUserModeProvider = FutureProvider<UserRole?>((ref) async {
  try {
    final profile = await SupabaseService.instance.getCurrentUserProfile();
    return profile?.currentMode;
  } catch (e) {
    return null;
  }
});