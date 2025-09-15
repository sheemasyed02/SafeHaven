import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkUpdatesScreen extends ConsumerStatefulWidget {
  const WorkUpdatesScreen({super.key});

  @override
  ConsumerState<WorkUpdatesScreen> createState() => _WorkUpdatesScreenState();
}

class _WorkUpdatesScreenState extends ConsumerState<WorkUpdatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Work Updates'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.access_time)),
            Tab(text: 'In Progress', icon: Icon(Icons.construction)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            Tab(text: 'Cancelled', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingJobs(),
          _buildInProgressJobs(),
          _buildCompletedJobs(),
          _buildCancelledJobs(),
        ],
      ),
    );
  }

  Widget _buildPendingJobs() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Mock data
      itemBuilder: (context, index) {
        return _buildJobCard(
          customerName: ['Alice Johnson', 'Bob Smith', 'Carol Wilson'][index],
          serviceType: ['House Painting', 'Electrical Repair', 'Garden Maintenance'][index],
          requestDate: ['Today, 10:00 AM', 'Tomorrow, 2:00 PM', 'Dec 20, 9:00 AM'][index],
          location: ['123 Main St, Downtown', '456 Oak Ave, Suburbs', '789 Pine Rd, City Center'][index],
          price: ['\$400', '\$150', '\$300'][index],
          description: [
            'Paint entire living room and kitchen walls',
            'Fix electrical outlets in master bedroom',
            'Trim hedges and plant new flowers in front yard'
          ][index],
          status: 'Pending',
          statusColor: Colors.orange,
          actions: [
            ElevatedButton(
              onPressed: () {
                // Accept job
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                // Decline job
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
              ),
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInProgressJobs() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2, // Mock data
      itemBuilder: (context, index) {
        return _buildJobCard(
          customerName: ['David Brown', 'Emma Wilson'][index],
          serviceType: ['Plumbing Repair', 'House Cleaning'][index],
          requestDate: ['Started 2 days ago', 'Started yesterday'][index],
          location: ['321 Elm St, Downtown', '654 Maple Ave, Suburbs'][index],
          price: ['\$120', '\$80'][index],
          description: [
            'Fix leaking pipes in bathroom and kitchen',
            'Deep clean entire house including carpets'
          ][index],
          status: 'In Progress',
          statusColor: Colors.blue,
          actions: [
            ElevatedButton(
              onPressed: () {
                // Update progress
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Progress'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Mark complete
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark Complete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompletedJobs() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Mock data
      itemBuilder: (context, index) {
        final jobs = [
          {'customer': 'Frank Miller', 'service': 'Carpentry Work', 'date': '1 week ago', 'location': '111 Cedar St', 'price': '\$250'},
          {'customer': 'Grace Lee', 'service': 'HVAC Maintenance', 'date': '2 weeks ago', 'location': '222 Birch Ave', 'price': '\$180'},
          {'customer': 'Henry Taylor', 'service': 'Roof Repair', 'date': '3 weeks ago', 'location': '333 Spruce Rd', 'price': '\$500'},
          {'customer': 'Ivy Chen', 'service': 'Interior Design', 'date': '1 month ago', 'location': '444 Willow St', 'price': '\$800'},
          {'customer': 'Jack Rodriguez', 'service': 'Appliance Repair', 'date': '2 months ago', 'location': '555 Poplar Ave', 'price': '\$95'},
        ];
        
        final job = jobs[index];
        return _buildJobCard(
          customerName: job['customer']!,
          serviceType: job['service']!,
          requestDate: job['date']!,
          location: job['location']!,
          price: job['price']!,
          description: 'Completed successfully with customer satisfaction',
          status: 'Completed',
          statusColor: Colors.green,
          actions: [
            OutlinedButton(
              onPressed: () {
                // View details
              },
              child: const Text('View Details'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Request review
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Request Review'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCancelledJobs() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1, // Mock data
      itemBuilder: (context, index) {
        return _buildJobCard(
          customerName: 'Kate Johnson',
          serviceType: 'Landscape Design',
          requestDate: '1 week ago',
          location: '777 Ash St, Suburbs',
          price: '\$600',
          description: 'Customer cancelled due to budget constraints',
          status: 'Cancelled',
          statusColor: Colors.red,
          actions: [
            OutlinedButton(
              onPressed: () {
                // View reason
              },
              child: const Text('View Reason'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJobCard({
    required String customerName,
    required String serviceType,
    required String requestDate,
    required String location,
    required String price,
    required String description,
    required String status,
    required Color statusColor,
    required List<Widget> actions,
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
                    serviceType,
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
                  'Customer: $customerName',
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
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
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
                  requestDate,
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
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}