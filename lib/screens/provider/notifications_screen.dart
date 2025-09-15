import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Job Request',
      'message': 'Alice Johnson requested painting service for tomorrow',
      'time': '5 minutes ago',
      'type': 'job_request',
      'isRead': false,
      'icon': Icons.work_outline,
      'color': Colors.blue,
    },
    {
      'title': 'Payment Received',
      'message': 'You received \$150 payment from Bob Smith',
      'time': '2 hours ago',
      'type': 'payment',
      'isRead': false,
      'icon': Icons.payment,
      'color': Colors.green,
    },
    {
      'title': 'Job Completed',
      'message': 'Carol Wilson marked your plumbing job as completed',
      'time': '1 day ago',
      'type': 'job_update',
      'isRead': true,
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'title': 'New Review',
      'message': 'David Brown left you a 5-star review',
      'time': '2 days ago',
      'type': 'review',
      'isRead': true,
      'icon': Icons.star,
      'color': Colors.orange,
    },
    {
      'title': 'Profile Verification',
      'message': 'Your electrician certification has been verified',
      'time': '3 days ago',
      'type': 'verification',
      'isRead': true,
      'icon': Icons.verified,
      'color': Colors.blue,
    },
    {
      'title': 'Booking Reminder',
      'message': 'You have a house cleaning job scheduled for tomorrow at 10 AM',
      'time': '1 week ago',
      'type': 'reminder',
      'isRead': true,
      'icon': Icons.schedule,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread notifications',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in _notifications) {
                    notification['isRead'] = true;
                  }
                });
              },
              child: const Text('Mark All Read'),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  // Navigate to notification settings
                  break;
                case 'clear_all':
                  setState(() {
                    _notifications.clear();
                  });
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Notification Settings'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear All'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification, index);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification['isRead'] ? 1 : 3,
      color: notification['isRead'] ? null : Colors.blue.shade50,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: notification['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            notification['icon'],
            color: notification['color'],
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: notification['isRead'] 
                      ? FontWeight.normal 
                      : FontWeight.bold,
                ),
              ),
            ),
            if (!notification['isRead'])
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification['time'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                setState(() {
                  notification['isRead'] = !notification['isRead'];
                });
                break;
              case 'delete':
                setState(() {
                  _notifications.removeAt(index);
                });
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_read',
              child: ListTile(
                leading: Icon(
                  notification['isRead'] 
                      ? Icons.mark_email_unread 
                      : Icons.mark_email_read,
                ),
                title: Text(
                  notification['isRead'] 
                      ? 'Mark as Unread' 
                      : 'Mark as Read',
                ),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                dense: true,
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap based on type
          switch (notification['type']) {
            case 'job_request':
              // Navigate to job details
              break;
            case 'payment':
              // Navigate to earnings
              break;
            case 'job_update':
              // Navigate to work updates
              break;
            case 'review':
              // Navigate to reviews
              break;
            case 'verification':
              // Navigate to profile
              break;
            case 'reminder':
              // Navigate to schedule
              break;
          }
          
          // Mark as read
          if (!notification['isRead']) {
            setState(() {
              notification['isRead'] = true;
            });
          }
        },
      ),
    );
  }
}