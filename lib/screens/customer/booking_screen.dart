import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile.dart';
import '../../models/service_models.dart';
import '../../services/booking_service.dart';
import '../../services/supabase_service.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final UserProfile provider;

  const BookingScreen({
    super.key,
    required this.provider,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  ServiceCategory? _selectedService;
  double _estimatedHours = 1.0;
  PaymentMethod _paymentMethod = PaymentMethod.escrow;

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return (widget.provider.hourlyRate ?? 0.0) * _estimatedHours;
  }

  double get _escrowFee {
    return _totalAmount * 0.02; // 2% escrow fee
  }

  double get _totalWithFees {
    return _totalAmount + _escrowFee;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating booking...'),
            ],
          ),
        ),
      );

      // Get current user
      final currentUser = await SupabaseService.instance.getCurrentUserProfile();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Create booking
      final booking = await BookingService.createBooking(
        customerId: currentUser.id,
        provider: widget.provider,
        serviceCategory: _selectedService!,
        title: '${_getServiceDisplayName(_selectedService!)} Service',
        description: _descriptionController.text.trim(),
        amount: _totalAmount,
        scheduledDate: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        location: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Booking Confirmed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your booking with ${widget.provider.name} has been confirmed.'),
                const SizedBox(height: 8),
                Text('Booking ID: ${booking.id}'),
                const SizedBox(height: 8),
                if (_paymentMethod == PaymentMethod.escrow)
                  const Text(
                    'Payment is held in escrow and will be released after service completion.',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/customer-dashboard');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          widget.provider.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.provider.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.provider.rating} (${widget.provider.totalReviews} reviews)',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${widget.provider.hourlyRate ?? 0}/hour',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Service Selection
              Text(
                'Select Service',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ServiceCategory>(
                value: _selectedService,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose a service',
                ),
                items: widget.provider.services.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(_getServiceDisplayName(service)),
                  );
                }).toList(),
                onChanged: (service) {
                  setState(() {
                    _selectedService = service;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Please select a service';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Date & Time Selection
              Text(
                'Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select Date',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select Time',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Duration
              Text(
                'Estimated Duration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _estimatedHours,
                min: 0.5,
                max: 8.0,
                divisions: 15,
                label: '${_estimatedHours.toStringAsFixed(1)} hours',
                onChanged: (value) {
                  setState(() {
                    _estimatedHours = value;
                  });
                },
              ),
              Text(
                '${_estimatedHours.toStringAsFixed(1)} hours (₹${_totalAmount.toStringAsFixed(0)})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Service Description
              Text(
                'Service Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe what you need help with...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the service needed';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Address
              Text(
                'Service Address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter complete address...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter service address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Payment Method
              Text(
                'Payment Method',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    RadioListTile<PaymentMethod>(
                      title: const Text('Escrow Payment (Recommended)'),
                      subtitle: const Text('Payment held safely until service completion'),
                      value: PaymentMethod.escrow,
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<PaymentMethod>(
                      title: const Text('Direct Payment'),
                      subtitle: const Text('Pay directly to provider'),
                      value: PaymentMethod.direct,
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Price Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Breakdown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Service (${_estimatedHours.toStringAsFixed(1)} hrs)'),
                          Text('₹${_totalAmount.toStringAsFixed(0)}'),
                        ],
                      ),
                      if (_paymentMethod == PaymentMethod.escrow) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Escrow Fee (2%)'),
                            Text('₹${_escrowFee.toStringAsFixed(0)}'),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${(_paymentMethod == PaymentMethod.escrow ? _totalWithFees : _totalAmount).toStringAsFixed(0)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Book Now Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  child: Text(
                    'Book Now - ₹${(_paymentMethod == PaymentMethod.escrow ? _totalWithFees : _totalAmount).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getServiceDisplayName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.plumber:
        return 'Plumbing Services';
      case ServiceCategory.electrician:
        return 'Electrical Services';
      case ServiceCategory.cleaner:
        return 'House Cleaning';
      case ServiceCategory.chef:
        return 'Cooking Services';
      case ServiceCategory.driver:
        return 'Driver Services';
      case ServiceCategory.tutor:
        return 'Tutoring';
      case ServiceCategory.babysitter:
        return 'Babysitting';
      case ServiceCategory.eldercare:
        return 'Elderly Care';
      case ServiceCategory.photographer:
        return 'Photography';
      case ServiceCategory.designer:
        return 'Graphic Design';
      case ServiceCategory.writer:
        return 'Content Writing';
      case ServiceCategory.consultant:
        return 'Web Development';
      case ServiceCategory.massage:
        return 'Massage Therapy';
      case ServiceCategory.fitness:
        return 'Fitness Training';
      case ServiceCategory.yoga:
        return 'Yoga Instruction';
      case ServiceCategory.computer:
        return 'Computer Repair';
      case ServiceCategory.mobile:
        return 'Mobile Repair';
      default:
        return category.toString().split('.').last.replaceAll('_', ' ');
    }
  }
}