import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile.dart';
import '../../widgets/role_widgets.dart';

class CustomerBrowseScreen extends ConsumerStatefulWidget {
  final ServiceCategory? initialCategory;

  const CustomerBrowseScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<CustomerBrowseScreen> createState() => _CustomerBrowseScreenState();
}

class _CustomerBrowseScreenState extends ConsumerState<CustomerBrowseScreen> {
  final _searchController = TextEditingController();
  ServiceCategory? _selectedCategory;
  double _minRating = 0.0;
  AvailabilityStatus? _availabilityFilter;
  String _sortBy = 'rating'; // rating, price, reviews
  
  // Mock data - in real app this would come from API
  List<UserProfile> _mockProviders = [
    UserProfile(
      id: '1',
      name: 'Rajesh Kumar',
      email: 'rajesh@example.com',
      role: UserRole.provider,
      currentMode: UserRole.provider,
      phone: '+91 9876543210',
      services: [ServiceCategory.plumber],
      bio: 'Experienced plumber with 10+ years of expertise in residential and commercial plumbing. Specialized in leak repairs, pipe installation, and emergency services.',
      rating: 4.8,
      completedJobs: 245,
      totalReviews: 198,
      location: 'Mumbai, Maharashtra',
      hourlyRate: 500.0,
      providerStatus: ProviderStatus.verified,
      availabilityStatus: AvailabilityStatus.available,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    UserProfile(
      id: '2',
      name: 'Priya Sharma',
      email: 'priya@example.com',
      role: UserRole.provider,
      currentMode: UserRole.provider,
      phone: '+91 9876543211',
      services: [ServiceCategory.cleaner],
      bio: 'Professional house cleaning services with eco-friendly products. Deep cleaning, regular maintenance, and post-construction cleanup available.',
      rating: 4.9,
      completedJobs: 156,
      totalReviews: 142,
      location: 'Delhi, India',
      hourlyRate: 300.0,
      providerStatus: ProviderStatus.verified,
      availabilityStatus: AvailabilityStatus.available,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now(),
    ),
    UserProfile(
      id: '3',
      name: 'Amit Singh',
      email: 'amit@example.com',
      role: UserRole.provider,
      currentMode: UserRole.provider,
      phone: '+91 9876543212',
      services: [ServiceCategory.electrician],
      bio: 'Licensed electrician providing safe and reliable electrical services. Home wiring, appliance installation, and electrical troubleshooting.',
      rating: 4.7,
      completedJobs: 89,
      totalReviews: 76,
      location: 'Bangalore, Karnataka',
      hourlyRate: 600.0,
      providerStatus: ProviderStatus.verified,
      availabilityStatus: AvailabilityStatus.busy,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    ),
    UserProfile(
      id: '4',
      name: 'Sneha Patel',
      email: 'sneha@example.com',
      role: UserRole.provider,
      currentMode: UserRole.provider,
      phone: '+91 9876543213',
      services: [ServiceCategory.chef],
      bio: 'Professional chef specializing in Indian, Continental and Chinese cuisine. Home parties, family functions, and daily meal preparation.',
      rating: 4.9,
      completedJobs: 203,
      totalReviews: 189,
      location: 'Pune, Maharashtra',
      hourlyRate: 800.0,
      providerStatus: ProviderStatus.verified,
      availabilityStatus: AvailabilityStatus.available,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserProfile> get _filteredProviders {
    var filtered = _mockProviders.where((provider) {
      // Category filter
      if (_selectedCategory != null && !provider.services.contains(_selectedCategory)) {
        return false;
      }
      
      // Search filter
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isNotEmpty) {
        final matchesName = provider.name.toLowerCase().contains(searchTerm);
        final matchesBio = provider.bio?.toLowerCase().contains(searchTerm) ?? false;
        final matchesLocation = provider.location?.toLowerCase().contains(searchTerm) ?? false;
        if (!matchesName && !matchesBio && !matchesLocation) {
          return false;
        }
      }
      
      // Rating filter
      if (provider.rating < _minRating) {
        return false;
      }
      
      // Availability filter
      if (_availabilityFilter != null && provider.availabilityStatus != _availabilityFilter) {
        return false;
      }
      
      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price':
        filtered.sort((a, b) => (a.hourlyRate ?? 0).compareTo(b.hourlyRate ?? 0));
        break;
      case 'reviews':
        filtered.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
        break;
    }

    return filtered;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Filter
                      Text(
                        'Service Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = null;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ...ServiceCategory.values.map((category) {
                            return FilterChip(
                              label: Text(category.displayName),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? category : null;
                                });
                                Navigator.pop(context);
                              },
                            );
                          }),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Rating Filter
                      Text(
                        'Minimum Rating',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _minRating,
                        min: 0.0,
                        max: 5.0,
                        divisions: 10,
                        label: '${_minRating.toStringAsFixed(1)} stars',
                        onChanged: (value) {
                          setState(() {
                            _minRating = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Availability Filter
                      Text(
                        'Availability',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _availabilityFilter == null,
                            onSelected: (selected) {
                              setState(() {
                                _availabilityFilter = null;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Available'),
                            selected: _availabilityFilter == AvailabilityStatus.available,
                            onSelected: (selected) {
                              setState(() {
                                _availabilityFilter = selected ? AvailabilityStatus.available : null;
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Busy'),
                            selected: _availabilityFilter == AvailabilityStatus.busy,
                            onSelected: (selected) {
                              setState(() {
                                _availabilityFilter = selected ? AvailabilityStatus.busy : null;
                              });
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sort Options
                      Text(
                        'Sort By',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Highest Rating'),
                            value: 'rating',
                            groupValue: _sortBy,
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Lowest Price'),
                            value: 'price',
                            groupValue: _sortBy,
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Most Reviews'),
                            value: 'reviews',
                            groupValue: _sortBy,
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProviders = _filteredProviders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Providers'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Badge(
              label: Text('${_getActiveFiltersCount()}'),
              isLabelVisible: _getActiveFiltersCount() > 0,
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search providers, services, or locations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Active Filters
          if (_getActiveFiltersCount() > 0) ...[
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedCategory!.displayName),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      ),
                    ),
                  if (_minRating > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('${_minRating.toStringAsFixed(1)}+ stars'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _minRating = 0.0;
                          });
                        },
                      ),
                    ),
                  if (_availabilityFilter != null)
                    Chip(
                      label: Text(_availabilityFilter!.value),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _availabilityFilter = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Results
          Expanded(
            child: filteredProviders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No providers found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or search terms',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) {
                      final provider = filteredProviders[index];
                      return _ProviderCard(provider: provider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_minRating > 0) count++;
    if (_availabilityFilter != null) count++;
    return count;
  }
}

class _ProviderCard extends StatelessWidget {
  final UserProfile provider;

  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to provider detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      provider.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Provider Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            VerificationStatusBadge(
                              status: provider.providerStatus!,
                              showText: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...provider.services.take(2).map((service) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                service.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            )),
                            Expanded(
                              child: Text(
                                provider.services.map((s) => s.displayName).join(', '),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.rating}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${provider.totalReviews} reviews)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.work_outline,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.completedJobs} jobs',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ProviderStatusBadge(provider: provider),
                      const SizedBox(height: 8),
                      if (provider.hourlyRate != null)
                        Text(
                          '₹${provider.hourlyRate!.toInt()}/hr',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              if (provider.bio != null) ...[
                const SizedBox(height: 12),
                Text(
                  provider.bio!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              if (provider.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.location!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Contact provider
                      },
                      icon: const Icon(Icons.message_outlined),
                      label: const Text('Message'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: provider.availabilityStatus == AvailabilityStatus.available
                          ? () {
                              context.push('/booking', extra: provider);
                            }
                          : null,
                      icon: const Icon(Icons.book_online),
                      label: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}