import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  ServiceCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Providers'),
        backgroundColor: theme.colorScheme.surfaceContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'switch_to_provider':
                  context.go('/provider-dashboard');
                  break;
                case 'logout':
                  ref.read(authStateProvider.notifier).signOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'switch_to_provider',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz),
                    SizedBox(width: 8),
                    Text('Switch to Provider'),
                  ],
                ),
              ),
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
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // All Services chip
                      FilterChip(
                        label: const Text('All Services'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      
                      // Category chips
                      ...ServiceCategory.values.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.displayName),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Providers List
          Expanded(
            child: _buildProvidersList(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/provider-registration'),
        icon: const Icon(Icons.work),
        label: const Text('Become a Provider'),
      ),
    );
  }

  Widget _buildProvidersList(ThemeData theme) {
    // Mock data for now - in real app this would come from Supabase
    final mockProviders = _getFilteredProviders();

    if (mockProviders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No providers found',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockProviders.length,
      itemBuilder: (context, index) {
        final provider = mockProviders[index];
        return _ProviderCard(
          provider: provider,
          onTap: () => _showProviderDetails(provider),
        );
      },
    );
  }

  List<MockProvider> _getFilteredProviders() {
    List<MockProvider> providers = _mockProviders;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      providers = providers.where((provider) {
        return provider.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               provider.bio.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               provider.services.any((service) => 
                 service.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      providers = providers.where((provider) {
        return provider.category == _selectedCategory;
      }).toList();
    }

    return providers;
  }

  void _showProviderDetails(MockProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProviderDetailsSheet(provider: provider),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final MockProvider provider;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      provider.name[0].toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.rating.toStringAsFixed(1)} (${provider.reviewCount} reviews)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: provider.isOnline
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: provider.isOnline ? Colors.green : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                provider.bio,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: provider.services.take(3).map((service) => Chip(
                  label: Text(
                    service,
                    style: const TextStyle(fontSize: 12),
                  ),
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
              if (provider.services.length > 3) ...[
                const SizedBox(height: 4),
                Text(
                  '+${provider.services.length - 3} more services',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderDetailsSheet extends StatelessWidget {
  final MockProvider provider;

  const _ProviderDetailsSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              provider.name[0].toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                      color: Colors.amber[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${provider.rating.toStringAsFixed(1)} (${provider.reviewCount} reviews)',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: provider.isOnline
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    provider.isOnline ? 'Available Now' : 'Currently Offline',
                                    style: TextStyle(
                                      color: provider.isOnline ? Colors.green : Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Bio
                      Text(
                        'About',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.bio,
                        style: theme.textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Services
                      Text(
                        'Services Offered',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.services.map((service) => Chip(
                          label: Text(service),
                        )).toList(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Implement messaging
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Messaging feature coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.message),
                              label: const Text('Message'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context.go('/booking', extra: provider);
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Book Now'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Mock data - replace with real Supabase data
class MockProvider {
  final String id;
  final String name;
  final String bio;
  final double rating;
  final int reviewCount;
  final List<String> services;
  final ServiceCategory category;
  final bool isOnline;

  MockProvider({
    required this.id,
    required this.name,
    required this.bio,
    required this.rating,
    required this.reviewCount,
    required this.services,
    required this.category,
    required this.isOnline,
  });
}

final List<MockProvider> _mockProviders = [
  MockProvider(
    id: '1',
    name: 'Sarah Johnson',
    bio: 'Professional house cleaner with 5+ years of experience. Eco-friendly products, reliable service.',
    rating: 4.8,
    reviewCount: 124,
    services: ['House Cleaning', 'Deep Cleaning', 'Office Cleaning'],
    category: ServiceCategory.cleaner,
    isOnline: true,
  ),
  MockProvider(
    id: '2',
    name: 'Mike Rodriguez',
    bio: 'Licensed plumber specializing in residential repairs, installations, and emergency services.',
    rating: 4.9,
    reviewCount: 89,
    services: ['Pipe Repair', 'Toilet Installation', 'Emergency Plumbing'],
    category: ServiceCategory.plumber,
    isOnline: true,
  ),
  MockProvider(
    id: '3',
    name: 'Emma Chen',
    bio: 'Certified electrician with expertise in home wiring, lighting, and electrical safety inspections.',
    rating: 4.7,
    reviewCount: 67,
    services: ['Wiring', 'Lighting Installation', 'Electrical Inspection'],
    category: ServiceCategory.electrician,
    isOnline: false,
  ),
  MockProvider(
    id: '4',
    name: 'David Williams',
    bio: 'Experienced gardener and landscaper. Transform your outdoor space with professional care.',
    rating: 4.6,
    reviewCount: 43,
    services: ['Lawn Care', 'Garden Design', 'Tree Trimming'],
    category: ServiceCategory.gardener,
    isOnline: true,
  ),
  MockProvider(
    id: '5',
    name: 'Lisa Parker',
    bio: 'Personal trainer and fitness coach helping you achieve your health and wellness goals.',
    rating: 4.9,
    reviewCount: 156,
    services: ['Personal Training', 'Nutrition Coaching', 'Group Fitness'],
    category: ServiceCategory.fitness,
    isOnline: true,
  ),
];