import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../home_screen.dart';
import '../provider/onboarding_screen.dart';
import '../database_test_screen.dart';

enum UserRole {
  customer('Customer', 'I need assistance and support', Icons.help_outline),
  provider('Service Provider', 'I provide professional services', Icons.work_outline);

  const UserRole(this.title, this.description, this.icon);
  
  final String title;
  final String description;
  final IconData icon;
}

enum ProviderType {
  electrician('Electrician', 'Electrical installations and repairs', Icons.electrical_services),
  plumber('Plumber', 'Plumbing installations and repairs', Icons.plumbing),
  cleaner('Cleaner', 'House and office cleaning services', Icons.cleaning_services),
  painter('Painter', 'Interior and exterior painting', Icons.format_paint),
  carpenter('Carpenter', 'Furniture and woodwork', Icons.carpenter),
  mechanic('Mechanic', 'Vehicle maintenance and repair', Icons.build),
  gardener('Gardener', 'Garden maintenance and landscaping', Icons.grass),
  cook('Cook/Chef', 'Cooking and catering services', Icons.restaurant),
  tutor('Tutor', 'Educational and tutoring services', Icons.school),
  security('Security Guard', 'Security and safety services', Icons.security),
  driver('Driver', 'Transportation services', Icons.local_taxi),
  other('Other', 'Other professional services', Icons.more_horiz);

  const ProviderType(this.title, this.description, this.icon);
  
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
  ProviderType? _selectedProviderType;
  bool _isLoading = false;
  bool _showProviderTypes = false;

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      if (role == UserRole.provider) {
        _showProviderTypes = true;
        _selectedProviderType = null;
      } else {
        _showProviderTypes = false;
        _selectedProviderType = null;
      }
    });
  }

  void _selectProviderType(ProviderType type) {
    setState(() {
      _selectedProviderType = type;
    });
  }

  bool get _canContinue {
    if (_selectedRole == null) return false;
    if (_selectedRole == UserRole.provider && _selectedProviderType == null) return false;
    return true;
  }

  Future<void> _continueWithRole() async {
    if (!_canContinue) return;

    print('Starting role update process...'); // Debug
    print('Selected role: $_selectedRole'); // Debug
    print('Selected provider type: $_selectedProviderType'); // Debug

    setState(() {
      _isLoading = true;
    });

    try {
      final roleValue = _selectedRole == UserRole.customer ? 'customer' : 'provider';
      print('Role value: $roleValue'); // Debug
      
      // Update role in database
      if (_selectedRole == UserRole.provider && _selectedProviderType != null) {
        print('Updating provider role with type'); // Debug
        await ref.read(authProvider.notifier).updateUserRole(
          roleValue, 
          providerType: _selectedProviderType!.title.toLowerCase(),
        );
      } else {
        print('Updating customer role'); // Debug
        await ref.read(authProvider.notifier).updateUserRole(roleValue);
      }
      
      print('Role update completed successfully'); // Debug
      
      if (mounted) {
        // Show success message first
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role set successfully as $roleValue'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Small delay to show the success message
        await Future.delayed(const Duration(seconds: 1));
        
        // Navigate based on role
        if (roleValue == 'provider') {
          print('Navigating to provider onboarding'); // Debug
          // Providers need to complete onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProviderOnboardingScreen(),
            ),
          );
        } else {
          print('Navigating to home screen'); // Debug
          // Customers go directly to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error in _continueWithRole: $e'); // Debug
      if (mounted) {
        String errorMessage = 'Failed to set role';
        String actionLabel = 'Debug';
        
        // Provide specific error messages
        if (e.toString().contains('column') && e.toString().contains('does not exist')) {
          errorMessage = 'Database setup issue. Please check DATABASE_DIAGNOSTIC.md in your project folder for setup instructions.';
        } else if (e.toString().contains('42501') || e.toString().contains('row-level security') || e.toString().contains('Row Level Security')) {
          errorMessage = 'Database permission issue (RLS Policy). Check RLS_POLICY_FIX.md for the complete solution.';
          actionLabel = 'Fix RLS';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Database permission issue. Please check your Supabase policies in RLS_POLICY_FIX.md.';
          actionLabel = 'Fix RLS';
        } else if (e.toString().contains('No authenticated user')) {
          errorMessage = 'Authentication error. Please log in again.';
        } else {
          errorMessage = 'Failed to set role: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DatabaseTestScreen(),
                  ),
                );
              },
            ),
          ),
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please complete role selection to continue'),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
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
                  _showProviderTypes 
                    ? 'Select your service type to help customers find you'
                    : 'Please select your role to complete the registration process.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Role Selection
                if (!_showProviderTypes) ...[
                  _buildRoleSelection(theme),
                ] else ...[
                  // Back button for provider types
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showProviderTypes = false;
                            _selectedProviderType = null;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Text(
                        'Service Provider Types',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProviderTypeSelection(theme),
                ],

                const SizedBox(height: 32),

                // Continue button
                CustomButton(
                  text: _isLoading ? 'Setting up...' : 'Complete Registration',
                  onPressed: (!_canContinue || _isLoading) ? () {} : _continueWithRole,
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
                          _showProviderTypes 
                            ? 'Select your primary service type. You can add more services later.'
                            : 'Role selection is required to access SafeHaven features',
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DatabaseTestScreen(),
              ),
            );
          },
          backgroundColor: Colors.orange,
          tooltip: 'Database Test',
          child: const Icon(Icons.bug_report, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRoleSelection(ThemeData theme) {
    return Column(
      children: UserRole.values.map((role) {
        final isSelected = _selectedRole == role;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: _isLoading ? null : () => _selectRole(role),
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
    );
  }

  Widget _buildProviderTypeSelection(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: ProviderType.values.length,
      itemBuilder: (context, index) {
        final providerType = ProviderType.values[index];
        final isSelected = _selectedProviderType == providerType;
        
        return InkWell(
          onTap: _isLoading ? null : () => _selectProviderType(providerType),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    providerType.icon,
                    color: isSelected 
                      ? Colors.white
                      : theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  providerType.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
