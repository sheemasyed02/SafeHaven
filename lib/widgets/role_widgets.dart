import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';

/// Role switching widget for dual-role users
class RoleSwitchToggle extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  final Function(UserRole)? onRoleChanged;

  const RoleSwitchToggle({
    super.key,
    required this.userProfile,
    this.onRoleChanged,
  });

  @override
  ConsumerState<RoleSwitchToggle> createState() => _RoleSwitchToggleState();
}

class _RoleSwitchToggleState extends ConsumerState<RoleSwitchToggle>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial position based on current mode
    if (widget.userProfile.currentMode == UserRole.provider) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _switchRole(UserRole newRole) async {
    if (_isLoading || newRole == widget.userProfile.currentMode) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Animate the toggle
      if (newRole == UserRole.provider) {
        await _animationController.forward();
      } else {
        await _animationController.reverse();
      }

      // Update user profile with new current mode
      final updatedProfile = widget.userProfile.copyWith(
        currentMode: newRole,
        updatedAt: DateTime.now(),
      );

      // Call auth provider to update profile
      await ref.read(authStateProvider.notifier).updateUserProfile(updatedProfile);

      // Notify parent widget
      widget.onRoleChanged?.call(newRole);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Switched to ${newRole == UserRole.customer ? 'Customer' : 'Provider'} mode',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert animation on error
      if (widget.userProfile.currentMode == UserRole.provider) {
        await _animationController.forward();
      } else {
        await _animationController.reverse();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch role: $e'),
            backgroundColor: Colors.red,
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
    final isCustomerMode = widget.userProfile.currentMode == UserRole.customer;

    if (!widget.userProfile.canSwitchRoles) {
      // Show current role only if switching is disabled
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCustomerMode ? Icons.person : Icons.work,
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              isCustomerMode ? 'Customer' : 'Provider',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Customer Mode Button
          GestureDetector(
            onTap: _isLoading ? null : () => _switchRole(UserRole.customer),
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                final isSelected = isCustomerMode;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Customer',
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 4),

          // Provider Mode Button
          GestureDetector(
            onTap: _isLoading ? null : () => _switchRole(UserRole.provider),
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                final isSelected = !isCustomerMode;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.work,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Provider',
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Status badge widget for providers
class ProviderStatusBadge extends StatelessWidget {
  final UserProfile provider;
  final bool showText;

  const ProviderStatusBadge({
    super.key,
    required this.provider,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!provider.isProvider || provider.availabilityStatus == null) {
      return const SizedBox.shrink();
    }

    Color badgeColor;
    Color textColor;
    IconData icon;
    String text;

    switch (provider.availabilityStatus!) {
      case AvailabilityStatus.available:
        badgeColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
        text = 'Available';
        break;
      case AvailabilityStatus.busy:
        badgeColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.schedule;
        text = 'Busy';
        break;
      case AvailabilityStatus.offline:
        badgeColor = Colors.grey;
        textColor = Colors.white;
        icon = Icons.circle;
        text = 'Offline';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 8 : 4,
        vertical: showText ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: showText ? 14 : 12,
            color: textColor,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Verification status badge for providers
class VerificationStatusBadge extends StatelessWidget {
  final ProviderStatus status;
  final bool showText;

  const VerificationStatusBadge({
    super.key,
    required this.status,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case ProviderStatus.verified:
        badgeColor = Colors.blue;
        textColor = Colors.white;
        icon = Icons.verified;
        text = 'Verified';
        break;
      case ProviderStatus.pending:
        badgeColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.hourglass_empty;
        text = 'Pending';
        break;
      case ProviderStatus.verifying:
        badgeColor = Colors.blue.shade300;
        textColor = Colors.white;
        icon = Icons.sync;
        text = 'Verifying';
        break;
      case ProviderStatus.rejected:
        badgeColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.cancel;
        text = 'Rejected';
        break;
      case ProviderStatus.suspended:
        badgeColor = Colors.grey;
        textColor = Colors.white;
        icon = Icons.pause_circle;
        text = 'Suspended';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 8 : 4,
        vertical: showText ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: showText ? 14 : 12,
            color: textColor,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}