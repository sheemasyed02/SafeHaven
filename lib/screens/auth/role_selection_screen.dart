import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../home_screen.dart';
import '../provider/onboarding_screen.dart';

enum UserRole {
  helpSeeker('Help Seeker', 'I need assistance and support', Icons.help_outline),
  volunteer('Volunteer', 'I want to help others in need', Icons.volunteer_activism),
  professional('Professional', 'I provide professional services', Icons.work_outline);

  const UserRole(this.title, this.description, this.icon);
  
  final String title;
  final String description;
  final IconData icon;
}

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selectedRole;
  bool _isLoading = false;

  Future<void> _continueWithRole() async {
    if (_selectedRole == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final roleValue = _selectedRole == UserRole.helpSeeker ? 'customer'
        : _selectedRole == UserRole.volunteer ? 'provider'
        : 'provider';
      await ref.read(authProvider.notifier).updateUserRole(roleValue);
      
      if (mounted) {
        // Navigate based on role
        if (roleValue == 'provider') {
          // Providers need to complete onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProviderOnboardingScreen(),
            ),
          );
        } else {
          // Customers go directly to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set role: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation - role selection is mandatory
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please complete role selection to continue'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
        return false;
      },
      child: Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Header
              Text(
                'Complete Your Registration',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Please select your role to complete the registration process. This step is required to continue.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Role options
              Expanded(
                child: Column(
                  children: UserRole.values.map((role) {
                    final isSelected = _selectedRole == role;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: _isLoading ? null : () {
                          setState(() {
                            _selectedRole = role;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.outline.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected 
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : theme.colorScheme.surface,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  role.icon,
                                  color: isSelected 
                                    ? Colors.white
                                    : theme.colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected 
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      role.description,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Continue button
              const SizedBox(height: 24),
              CustomButton(
                text: _isLoading ? 'Setting up...' : 'Complete Registration',
                onPressed: (_selectedRole == null || _isLoading) ? () {} : _continueWithRole,
                backgroundColor: theme.colorScheme.primary,
              ),
              
              // Info text
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Role selection is required to access SafeHaven features',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
