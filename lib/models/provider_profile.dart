class ProviderProfile {
  final String id;
  final String userId;
  final String bio;
  final List<String> skills;
  final List<String> categories;
  final String idImageUrl;
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProviderProfile({
    required this.id,
    required this.userId,
    required this.bio,
    required this.skills,
    required this.categories,
    required this.idImageUrl,
    required this.verificationStatus,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create ProviderProfile from JSON
  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'].toString(),
      userId: json['user_id'],
      bio: json['bio'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      idImageUrl: json['id_image_url'] ?? '',
      verificationStatus: json['verification_status'] ?? 'pending',
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
    );
  }

  /// Convert ProviderProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bio': bio,
      'skills': skills,
      'categories': categories,
      'id_image_url': idImageUrl,
      'verification_status': verificationStatus,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  ProviderProfile copyWith({
    String? id,
    String? userId,
    String? bio,
    List<String>? skills,
    List<String>? categories,
    String? idImageUrl,
    String? verificationStatus,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      categories: categories ?? this.categories,
      idImageUrl: idImageUrl ?? this.idImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if provider is verified and active
  bool get isVerifiedAndActive => verificationStatus == 'verified' && isActive;

  /// Get verification status display text
  String get verificationStatusDisplay {
    switch (verificationStatus) {
      case 'pending':
        return 'Verification Pending';
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Verification Rejected';
      default:
        return 'Unknown Status';
    }
  }
}
