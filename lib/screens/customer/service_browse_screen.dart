import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/supabase_service.dart';
import '../../widgets/provider_card.dart';

class ServiceBrowseScreen extends StatefulWidget {
  const ServiceBrowseScreen({super.key});

  @override
  State<ServiceBrowseScreen> createState() => _ServiceBrowseScreenState();
}

class _ServiceBrowseScreenState extends State<ServiceBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _providers = [];
  List<UserProfile> _filteredProviders = [];
  final List<String> _selectedServices = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Available service categories - using enum values
  final List<String> _serviceCategories = [
    'Plumbing Services',
    'Electrical Services', 
    'Painting Services',
    'Carpentry Services',
    'Cleaning Services',
    'Gardening Services',
    'Cooking Services',
    'Baking Services',
    'Catering Services',
    'Tutoring Services',
    'Driving Services',
    'Babysitting Services',
    'Elder Care Services',
    'Photography Services',
    'Design Services',
    'Writing Services',
    'Consulting Services',
    'Massage Therapy',
    'Fitness Training',
    'Yoga Instruction',
    'Computer Repair',
    'Mobile Repair',
    'Other Services',
  ];

  @override
  void initState() {
    super.initState();
    _loadProviders();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final providers = await SupabaseService.instance.getProviders();
      setState(() {
        _providers = providers;
        _filteredProviders = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading providers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterProviders();
  }

  void _filterProviders() {
    setState(() {
      _filteredProviders = _providers.where((provider) {
        final matchesSearch = _searchQuery.isEmpty ||
            provider.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (provider.bio?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        final matchesServices = _selectedServices.isEmpty ||
            _selectedServices.any((service) => 
                provider.services.any((s) => s.displayName == service));

        return matchesSearch && matchesServices;
      }).toList();
    });
  }

  void _toggleServiceFilter(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
    _filterProviders();
  }

  void _clearFilters() {
    setState(() {
      _selectedServices.clear();
      _searchController.clear();
      _searchQuery = '';
    });
    _filterProviders();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search providers by name or bio...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildServiceFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _serviceCategories.length,
              itemBuilder: (context, index) {
                final service = _serviceCategories[index];
                final isSelected = _selectedServices.contains(service);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(service),
                    selected: isSelected,
                    onSelected: (_) => _toggleServiceFilter(service),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          if (_selectedServices.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
              tooltip: 'Clear filters',
            ),
        ],
      ),
    );
  }

  Widget _buildProvidersGrid() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filteredProviders.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                _providers.isEmpty 
                    ? 'No providers available yet'
                    : 'No providers match your search',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _providers.isEmpty 
                    ? 'Check back later for service providers'
                    : 'Try adjusting your search or filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              if (_selectedServices.isNotEmpty || _searchQuery.isNotEmpty) ...[
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear filters'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _loadProviders,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _filteredProviders.length,
          itemBuilder: (context, index) {
            return ProviderCard(
              provider: _filteredProviders[index],
              onTap: () {
                // TODO: Navigate to provider detail screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped on ${_filteredProviders[index].name}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Services'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProviders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildServiceFilters(),
          const Divider(height: 1),
          _buildProvidersGrid(),
        ],
      ),
    );
  }
}