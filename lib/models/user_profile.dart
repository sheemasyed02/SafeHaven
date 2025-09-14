/// User role enumeration
enum UserRole {
  customer('customer'),
  provider('provider');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }
}

/// Provider verification status
enum ProviderStatus {
  pending('pending'),           // Just registered, awaiting verification
  verifying('verifying'),       // Under review by admin
  verified('verified'),         // Approved and can accept jobs
  rejected('rejected'),         // Verification failed
  suspended('suspended');       // Temporarily disabled

  const ProviderStatus(this.value);
  final String value;

  static ProviderStatus fromString(String value) {
    for (ProviderStatus status in ProviderStatus.values) {
      if (status.value == value) return status;
    }
    return ProviderStatus.pending;
  }
}

/// Provider availability status
enum AvailabilityStatus {
  available('available'),
  busy('busy'),
  offline('offline');

  const AvailabilityStatus(this.value);
  final String value;

  static AvailabilityStatus fromString(String value) {
    for (AvailabilityStatus status in AvailabilityStatus.values) {
      if (status.value == value) return status;
    }
    return AvailabilityStatus.offline;
  }
}

/// Service categories for providers
enum ServiceCategory {
  // Home Services
  plumber('plumber', 'Plumbing Services', '🔧'),
  electrician('electrician', 'Electrical Services', '⚡'),
  painter('painter', 'Painting Services', '🎨'),
  carpenter('carpenter', 'Carpentry Services', '🔨'),
  cleaner('cleaner', 'Cleaning Services', '🧹'),
  gardener('gardener', 'Gardening Services', '🌱'),
  
  // Food Services
  chef('chef', 'Cooking Services', '👨‍🍳'),
  baker('baker', 'Baking Services', '🍰'),
  caterer('caterer', 'Catering Services', '🍽️'),
  
  // Personal Services
  tutor('tutor', 'Tutoring Services', '📚'),
  driver('driver', 'Driving Services', '🚗'),
  babysitter('babysitter', 'Babysitting Services', '👶'),
  eldercare('eldercare', 'Elder Care Services', '👴'),
  
  // Professional Services
  photographer('photographer', 'Photography Services', '📸'),
  designer('designer', 'Design Services', '🎨'),
  writer('writer', 'Writing Services', '✍️'),
  consultant('consultant', 'Consulting Services', '💼'),
  
  // Health & Wellness
  massage('massage', 'Massage Therapy', '💆'),
  fitness('fitness', 'Fitness Training', '💪'),
  yoga('yoga', 'Yoga Instruction', '🧘'),
  
  // Tech Services
  computer('computer', 'Computer Repair', '💻'),
  mobile('mobile', 'Mobile Repair', '📱'),
  
  // Other
  other('other', 'Other Services', '🔧');

  const ServiceCategory(this.value, this.displayName, this.emoji);
  final String value;
  final String displayName;
  final String emoji;

  static ServiceCategory fromString(String value) {
    for (ServiceCategory category in ServiceCategory.values) {
      if (category.value == value.toLowerCase()) {
        return category;
      }
    }
    return ServiceCategory.other;
  }
}

/// Enhanced user profile model for services platform
class UserProfile {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Provider-specific fields
  final ProviderStatus? providerStatus;
  final AvailabilityStatus? availabilityStatus;
  final List<ServiceCategory> services;
  final String? customService; // For "Other" category
  final String? bio;
  final String? verificationVideoUrl;
  final double rating;
  final int completedJobs;
  final int totalReviews;
  final String? location;
  final double? hourlyRate;
  
  // Dual role support
  final UserRole currentMode; // Which mode user is currently in
  final bool canSwitchRoles; // Whether user can switch between roles

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    
    // Provider fields
    this.providerStatus,
    this.availabilityStatus,
    this.services = const [],
    this.customService,
    this.bio,
    this.verificationVideoUrl,
    this.rating = 0.0,
    this.completedJobs = 0,
    this.totalReviews = 0,
    this.location,
    this.hourlyRate,
    
    // Dual role fields
    UserRole? currentMode,
    this.canSwitchRoles = true,
  }) : currentMode = currentMode ?? role;

  /// Create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      
      // Provider fields
      providerStatus: json['provider_status'] != null 
          ? ProviderStatus.fromString(json['provider_status'] as String) 
          : null,
      availabilityStatus: json['availability_status'] != null 
          ? AvailabilityStatus.fromString(json['availability_status'] as String) 
          : null,
      services: (json['services'] as List<dynamic>?)
          ?.map((s) => ServiceCategory.fromString(s as String))
          .toList() ?? [],
      customService: json['custom_service'] as String?,
      bio: json['bio'] as String?,
      verificationVideoUrl: json['verification_video_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedJobs: (json['completed_jobs'] as int?) ?? 0,
      totalReviews: (json['total_reviews'] as int?) ?? 0,
      location: json['location'] as String?,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      
      // Dual role fields
      currentMode: json['current_mode'] != null 
          ? UserRole.fromString(json['current_mode'] as String)
          : null,
      canSwitchRoles: (json['can_switch_roles'] as bool?) ?? true,
    );
  }

  /// Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      
      // Provider fields
      'provider_status': providerStatus?.value,
      'availability_status': availabilityStatus?.value,
      'services': services.map((s) => s.value).toList(),
      'custom_service': customService,
      'bio': bio,
      'verification_video_url': verificationVideoUrl,
      'rating': rating,
      'completed_jobs': completedJobs,
      'total_reviews': totalReviews,
      'location': location,
      'hourly_rate': hourlyRate,
      
      // Dual role fields
      'current_mode': currentMode.value,
      'can_switch_roles': canSwitchRoles,
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    
    // Provider fields
    ProviderStatus? providerStatus,
    AvailabilityStatus? availabilityStatus,
    List<ServiceCategory>? services,
    String? customService,
    String? bio,
    String? verificationVideoUrl,
    double? rating,
    int? completedJobs,
    int? totalReviews,
    String? location,
    double? hourlyRate,
    
    // Dual role fields
    UserRole? currentMode,
    bool? canSwitchRoles,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      
      // Provider fields
      providerStatus: providerStatus ?? this.providerStatus,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      services: services ?? this.services,
      customService: customService ?? this.customService,
      bio: bio ?? this.bio,
      verificationVideoUrl: verificationVideoUrl ?? this.verificationVideoUrl,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      totalReviews: totalReviews ?? this.totalReviews,
      location: location ?? this.location,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      
      // Dual role fields
      currentMode: currentMode ?? this.currentMode,
      canSwitchRoles: canSwitchRoles ?? this.canSwitchRoles,
    );
  }

  /// Helper methods
  bool get isProvider => role == UserRole.provider;
  bool get isCustomer => role == UserRole.customer;
  bool get isVerifiedProvider => isProvider && providerStatus == ProviderStatus.verified;
  bool get isAvailable => availabilityStatus == AvailabilityStatus.available;
  bool get canAcceptJobs => isVerifiedProvider && isAvailable;
  
  String get displayRole {
    if (isProvider && services.isNotEmpty) {
      if (services.contains(ServiceCategory.other) && customService != null) {
        return customService!;
      }
      return services.first.displayName;
    }
    return role.value.toUpperCase();
  }

  String get statusBadge {
    if (isProvider) {
      switch (availabilityStatus) {
        case AvailabilityStatus.available:
          return '🟢 Available';
        case AvailabilityStatus.busy:
          return '🔴 Busy';
        case AvailabilityStatus.offline:
          return '⚫ Offline';
        default:
          return '⚫ Offline';
      }
    }
    return '';
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, role: ${role.value}, currentMode: ${currentMode.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}