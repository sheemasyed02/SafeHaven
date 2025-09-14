import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeHaven'),
        backgroundColor: theme.colorScheme.surfaceContainer,
        actions: [
          if (user != null) ...[
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/profile'),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authStateProvider.notifier).signOut();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('Sign Up'),
            ),
          ],
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(user: user),
          _BrowseTab(),
          _ServicesTab(),
          _ProfileTab(user: user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final dynamic user;

  const _HomeTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Welcome Section
          Icon(
            Icons.home_work,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          
          Text(
            'Welcome to SafeHaven',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Your trusted marketplace for local services',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          if (user == null) ...[
            // Not logged in - show signup prompts
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get Started',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Join SafeHaven to connect with trusted local service providers or offer your own services.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('Sign Up'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Logged in - show profile completion prompt
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Complete your profile setup to access your personalized dashboard and start using SafeHaven services.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Complete Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // What SafeHaven Offers
          Text(
            'What SafeHaven Offers',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          const _FeatureCard(
            icon: Icons.search,
            title: 'Find Services',
            description: 'Browse and book trusted local service providers',
            color: Colors.blue,
          ),
          
          const SizedBox(height: 12),
          
          const _FeatureCard(
            icon: Icons.work,
            title: 'Offer Services',
            description: 'Become a provider and grow your business',
            color: Colors.green,
          ),
          
          const SizedBox(height: 12),
          
          const _FeatureCard(
            icon: Icons.security,
            title: 'Secure Payments',
            description: 'Protected escrow system for all transactions',
            color: Colors.orange,
          ),
          
          const SizedBox(height: 12),
          
          const _FeatureCard(
            icon: Icons.star,
            title: 'Reviews & Ratings',
            description: 'Transparent feedback system for quality assurance',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

// Browse Tab - Shows service categories
class _BrowseTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('Browse Services', style: TextStyle(fontSize: 24)),
          Text('Browse and search for service providers'),
        ],
      ),
    );
  }
}

// Services Tab - Manage your services if you're a provider
class _ServicesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('My Services', style: TextStyle(fontSize: 24)),
          Text('Manage your service offerings'),
        ],
      ),
    );
  }
}

// Profile Tab - User profile and settings
class _ProfileTab extends StatelessWidget {
  final dynamic user;

  const _ProfileTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Profile', style: TextStyle(fontSize: 24)),
          Text('Manage your profile and settings'),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}