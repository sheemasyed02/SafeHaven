import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ProviderProfileScreen extends ConsumerWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.business,
                      size: 60,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authState.user?.email ?? 'Provider',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'SafeHaven Service Provider',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('4.8', 'Rating'),
                      _buildStatItem('156', 'Reviews'),
                      _buildStatItem('89%', 'Success Rate'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Business Info Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Business Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              icon: Icons.business_center,
              title: 'Services Offered',
              subtitle: 'Manage your service categories',
              onTap: () {
                // Navigate to services management
              },
            ),
            _buildProfileOption(
              icon: Icons.schedule,
              title: 'Availability',
              subtitle: 'Set your working hours',
              onTap: () {
                // Navigate to availability settings
              },
            ),
            _buildProfileOption(
              icon: Icons.location_on_outlined,
              title: 'Service Areas',
              subtitle: 'Manage your coverage areas',
              onTap: () {
                // Navigate to service areas
              },
            ),
            _buildProfileOption(
              icon: Icons.attach_money,
              title: 'Pricing',
              subtitle: 'Set your service rates',
              onTap: () {
                // Navigate to pricing
              },
            ),
            
            const SizedBox(height: 24),
            
            // Account Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account & Verification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Update your personal details',
              onTap: () {
                // Navigate to personal info
              },
            ),
            _buildProfileOption(
              icon: Icons.verified_outlined,
              title: 'Verification Status',
              subtitle: 'View your verification badges',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () {
                // Navigate to verification
              },
            ),
            _buildProfileOption(
              icon: Icons.description_outlined,
              title: 'Documents',
              subtitle: 'Manage certificates and licenses',
              onTap: () {
                // Navigate to documents
              },
            ),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title: 'Payment Settings',
              subtitle: 'Bank account and payment options',
              onTap: () {
                // Navigate to payment settings
              },
            ),
            
            const SizedBox(height: 24),
            
            // Performance Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Performance & Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              icon: Icons.bar_chart,
              title: 'Earnings Report',
              subtitle: 'View your income analytics',
              onTap: () {
                // Navigate to earnings
              },
            ),
            _buildProfileOption(
              icon: Icons.star_outline,
              title: 'Reviews & Ratings',
              subtitle: 'Customer feedback and ratings',
              onTap: () {
                // Navigate to reviews
              },
            ),
            _buildProfileOption(
              icon: Icons.analytics_outlined,
              title: 'Performance Metrics',
              subtitle: 'Job completion and success rates',
              onTap: () {
                // Navigate to metrics
              },
            ),
            
            const SizedBox(height: 24),
            
            // App Settings Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'App Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: 'Notification Settings',
              subtitle: 'Manage your notification preferences',
              onTap: () {
                // Navigate to notification settings
              },
            ),
            _buildProfileOption(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Account security settings',
              onTap: () {
                // Navigate to security settings
              },
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
                // Navigate to help
              },
            ),
            
            const SizedBox(height: 24),
            
            // Role Switch
            Card(
              child: ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Switch to Customer'),
                subtitle: const Text('View as a customer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to customer dashboard
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.green.shade600,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}