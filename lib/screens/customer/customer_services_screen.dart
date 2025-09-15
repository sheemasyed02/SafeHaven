import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerServicesScreen extends ConsumerStatefulWidget {
  const CustomerServicesScreen({super.key});

  @override
  ConsumerState<CustomerServicesScreen> createState() => _CustomerServicesScreenState();
}

class _CustomerServicesScreenState extends ConsumerState<CustomerServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            Tab(text: 'Cancelled', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveServices(),
          _buildCompletedServices(),
          _buildCancelledServices(),
        ],
      ),
    );
  }

  Widget _buildActiveServices() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2, // Mock data
      itemBuilder: (context, index) {
        return _buildServiceCard(
          serviceName: index == 0 ? 'House Painting' : 'Electrical Repair',
          providerName: index == 0 ? 'John Smith' : 'David Wilson',
          status: index == 0 ? 'In Progress' : 'Scheduled',
          statusColor: index == 0 ? Colors.orange : Colors.blue,
          date: index == 0 ? 'Started 2 days ago' : 'Tomorrow, 10:00 AM',
          price: index == 0 ? '\$400' : '\$150',
          isActive: true,
        );
      },
    );
  }

  Widget _buildCompletedServices() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Mock data
      itemBuilder: (context, index) {
        final services = [
          {'name': 'Plumbing Repair', 'provider': 'Mike Johnson', 'date': '2 weeks ago', 'price': '\$80'},
          {'name': 'House Cleaning', 'provider': 'Maria Garcia', 'date': '1 month ago', 'price': '\$120'},
          {'name': 'Garden Maintenance', 'provider': 'Sarah Davis', 'date': '2 months ago', 'price': '\$200'},
        ];
        
        final service = services[index];
        return _buildServiceCard(
          serviceName: service['name']!,
          providerName: service['provider']!,
          status: 'Completed',
          statusColor: Colors.green,
          date: service['date']!,
          price: service['price']!,
          isActive: false,
        );
      },
    );
  }

  Widget _buildCancelledServices() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1, // Mock data
      itemBuilder: (context, index) {
        return _buildServiceCard(
          serviceName: 'Carpentry Work',
          providerName: 'Tom Brown',
          status: 'Cancelled',
          statusColor: Colors.red,
          date: '1 week ago',
          price: '\$300',
          isActive: false,
        );
      },
    );
  }

  Widget _buildServiceCard({
    required String serviceName,
    required String providerName,
    required String status,
    required Color statusColor,
    required String date,
    required String price,
    required bool isActive,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Provider: $providerName',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Contact provider
                      },
                      child: const Text('Contact Provider'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // View details
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'Completed') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Rate service
                      },
                      child: const Text('Rate Service'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Book again
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Book Again'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}