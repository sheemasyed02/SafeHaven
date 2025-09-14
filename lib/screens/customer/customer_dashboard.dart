import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import 'service_browse_screen.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const ServiceBrowseScreen(),
    const CustomerBookingsScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Customer Bookings Screen
class CustomerBookingsScreen extends ConsumerWidget {
  const CustomerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          // Role switch menu
          userProfileAsync.when(
            data: (userProfile) => userProfile?.canSwitchRoles == true
                ? PopupMenuButton<String>(
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Switch Role',
                    onSelected: (value) {
                      switch (value) {
                        case 'switch_to_provider':
                          context.go('/provider-dashboard');
                          break;
                        case 'logout':
                          ref.read(authStateProvider.notifier).signOut();
                          context.go('/login');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'switch_to_provider',
                        child: ListTile(
                          leading: Icon(Icons.business),
                          title: Text('Switch to Provider'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                          dense: true,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your booking history will appear here',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Customer Profile Screen
class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          // Role switch menu
          userProfileAsync.when(
            data: (userProfile) => userProfile?.canSwitchRoles == true
                ? PopupMenuButton<String>(
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Switch Role',
                    onSelected: (value) {
                      switch (value) {
                        case 'switch_to_provider':
                          context.go('/provider-dashboard');
                          break;
                        case 'logout':
                          ref.read(authStateProvider.notifier).signOut();
                          context.go('/login');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'switch_to_provider',
                        child: ListTile(
                          leading: Icon(Icons.business),
                          title: Text('Switch to Provider'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                          dense: true,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (userProfile) => userProfile == null
            ? const Center(child: Text('No profile found'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: userProfile.avatarUrl != null
                          ? NetworkImage(userProfile.avatarUrl!)
                          : null,
                      child: userProfile.avatarUrl == null
                          ? Text(
                              userProfile.name.isNotEmpty
                                  ? userProfile.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Name
                    Text(
                      userProfile.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Email
                    Text(
                      userProfile.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Customer',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Profile options
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Edit Profile'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Navigate to edit profile
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit profile coming soon')),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.notifications_outlined),
                            title: const Text('Notifications'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Navigate to notifications
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notifications coming soon')),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('Help & Support'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Navigate to help
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Help & Support coming soon')),
                              );
                            },
                          ),
                          if (userProfile.canSwitchRoles) ...[
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.business),
                              title: const Text('Switch to Provider Mode'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.go('/provider-dashboard');
                              },
                            ),
                          ],
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Logout'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ref.read(authStateProvider.notifier).signOut();
                              context.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }
}