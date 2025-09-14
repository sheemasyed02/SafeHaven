import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile.dart';
import '../../models/service_models.dart';
import '../../providers/auth_provider.dart';
import 'dart:io';

class ProviderRegistrationScreen extends ConsumerStatefulWidget {
  final UserProfile userProfile;

  const ProviderRegistrationScreen({
    super.key,
    required this.userProfile,
  });

  @override
  ConsumerState<ProviderRegistrationScreen> createState() => _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends ConsumerState<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _customServiceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _locationController = TextEditingController();

  List<ServiceCategory> _selectedServices = [];
  File? _verificationVideo;
  List<File> _documents = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _bioController.dispose();
    _customServiceController.dispose();
    _hourlyRateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickVerificationVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );
      
      if (video != null) {
        setState(() {
          _verificationVideo = File(video.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      
      if (video != null) {
        setState(() {
          _verificationVideo = File(video.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickDocuments() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      setState(() {
        _documents.addAll(images.map((image) => File(image.path)));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select documents: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleService(ServiceCategory service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
        if (service == ServiceCategory.other) {
          _customServiceController.clear();
        }
      } else {
        _selectedServices.add(service);
      }
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_verificationVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a verification video'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would upload files and create verification application
      // For now, we'll simulate the process and store the application data
      
      // This would be saved to the database in a real implementation
      final _ = VerificationApplication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        providerId: widget.userProfile.id,
        requestedServices: _selectedServices,
        customServiceName: _selectedServices.contains(ServiceCategory.other) 
            ? _customServiceController.text.trim() 
            : null,
        verificationVideoUrl: 'temp_video_url', // Would be uploaded URL
        documentUrls: _documents.map((doc) => 'temp_doc_url').toList(), // Would be uploaded URLs
        bio: _bioController.text.trim(),
        submittedAt: DateTime.now(),
      );

      // Update user profile to provider status
      final updatedProfile = widget.userProfile.copyWith(
        role: UserRole.provider,
        currentMode: UserRole.provider,
        providerStatus: ProviderStatus.pending,
        availabilityStatus: AvailabilityStatus.offline,
        services: _selectedServices,
        customService: _selectedServices.contains(ServiceCategory.other) 
            ? _customServiceController.text.trim() 
            : null,
        bio: _bioController.text.trim(),
        location: _locationController.text.trim().isNotEmpty 
            ? _locationController.text.trim() 
            : null,
        hourlyRate: _hourlyRateController.text.trim().isNotEmpty 
            ? double.tryParse(_hourlyRateController.text.trim()) 
            : null,
        updatedAt: DateTime.now(),
      );

      await ref.read(authStateProvider.notifier).updateUserProfile(updatedProfile);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: const Text('Application Submitted!'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your provider verification application has been submitted successfully.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Our team will review your application and video within 24-48 hours. You\'ll receive a notification once the review is complete.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  context.go('/provider-dashboard');
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Provider'),
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
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Provider Verification',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join SafeHaven as a Service Provider',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your verification to start offering services and earning money on SafeHaven.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Service Selection
              Text(
                'Select Your Services',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the services you want to offer (you can select multiple)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Service Categories Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: ServiceCategory.values.length,
                itemBuilder: (context, index) {
                  final service = ServiceCategory.values[index];
                  final isSelected = _selectedServices.contains(service);

                  return Card(
                    elevation: isSelected ? 4 : 1,
                    child: InkWell(
                      onTap: () => _toggleService(service),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              service.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              service.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Custom Service Field
              if (_selectedServices.contains(ServiceCategory.other)) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customServiceController,
                  decoration: const InputDecoration(
                    labelText: 'Specify Your Service',
                    hintText: 'Enter the specific service you offer',
                    prefixIcon: Icon(Icons.edit),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedServices.contains(ServiceCategory.other) &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please specify your service';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Bio Section
              Text(
                'About Yourself',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell customers about your experience, skills, and what makes you special...',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your bio';
                  }
                  if (value.trim().length < 50) {
                    return 'Bio must be at least 50 characters long';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Location and Rate
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (Optional)',
                        hintText: 'Your city/area',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _hourlyRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate (Optional)',
                        hintText: '₹500',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Verification Video Section
              Text(
                'Verification Video',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Record a 30-90 second video showcasing your skills. This helps customers trust your expertise.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              if (_verificationVideo == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickVerificationVideo,
                        icon: const Icon(Icons.videocam),
                        label: const Text('Record Video'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.video_library),
                        label: const Text('Choose from Gallery'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.video_file, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Verification Video',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Video selected successfully',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _verificationVideo = null;
                            });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Documents Section
              Text(
                'Supporting Documents (Optional)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload certificates, ID proof, or other relevant documents to strengthen your application.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _pickDocuments,
                icon: const Icon(Icons.attach_file),
                label: Text('Add Documents (${_documents.length})'),
              ),

              if (_documents.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _documents.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Chip(
                      label: Text('Document ${index + 1}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _documents.removeAt(index);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting Application...'),
                          ],
                        )
                      : const Text('Submit Application'),
                ),
              ),

              const SizedBox(height: 16),

              // Info Card
              Card(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'What happens next?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Our team reviews your application and video\n'
                        '2. You receive approval notification (24-48 hours)\n'
                        '3. Your profile becomes visible to customers\n'
                        '4. You can start accepting service requests',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}