import '../models/user_profile.dart';

/// Payment method enum for bookings
enum PaymentMethod {
  escrow('escrow'),
  direct('direct');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromString(String value) {
    for (PaymentMethod method in PaymentMethod.values) {
      if (method.value == value) return method;
    }
    return PaymentMethod.escrow;
  }
}

/// Service booking model
class ServiceBooking {
  final String id;
  final String customerId;
  final String providerId;
  final ServiceCategory serviceCategory;
  final String? customServiceName;
  final String title;
  final String description;
  final double amount;
  final BookingStatus status;
  final DateTime scheduledDate;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final String? escrowTransactionId;
  final PaymentStatus paymentStatus;
  final DateTime? paidAt;
  final DateTime? releasedAt;

  ServiceBooking({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceCategory,
    this.customServiceName,
    required this.title,
    required this.description,
    required this.amount,
    required this.status,
    required this.scheduledDate,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.escrowTransactionId,
    this.paymentStatus = PaymentStatus.pending,
    this.paidAt,
    this.releasedAt,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      serviceCategory: ServiceCategory.fromString(json['service_category'] as String),
      customServiceName: json['custom_service_name'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: BookingStatus.fromString(json['status'] as String),
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      escrowTransactionId: json['escrow_transaction_id'] as String?,
      paymentStatus: PaymentStatus.fromString(json['payment_status'] as String? ?? 'pending'),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      releasedAt: json['released_at'] != null ? DateTime.parse(json['released_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'provider_id': providerId,
      'service_category': serviceCategory.value,
      'custom_service_name': customServiceName,
      'title': title,
      'description': description,
      'amount': amount,
      'status': status.value,
      'scheduled_date': scheduledDate.toIso8601String(),
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'escrow_transaction_id': escrowTransactionId,
      'payment_status': paymentStatus.value,
      'paid_at': paidAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
    };
  }

  ServiceBooking copyWith({
    String? id,
    String? customerId,
    String? providerId,
    ServiceCategory? serviceCategory,
    String? customServiceName,
    String? title,
    String? description,
    double? amount,
    BookingStatus? status,
    DateTime? scheduledDate,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? escrowTransactionId,
    PaymentStatus? paymentStatus,
    DateTime? paidAt,
    DateTime? releasedAt,
  }) {
    return ServiceBooking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      customServiceName: customServiceName ?? this.customServiceName,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      escrowTransactionId: escrowTransactionId ?? this.escrowTransactionId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAt: paidAt ?? this.paidAt,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }
}

/// Booking status enumeration
enum BookingStatus {
  pending('pending'),           // Booking created, awaiting provider acceptance
  accepted('accepted'),         // Provider accepted the booking
  inProgress('in_progress'),    // Work has started
  completed('completed'),       // Work completed by provider
  customerApproved('customer_approved'), // Customer confirmed completion
  cancelled('cancelled'),       // Booking cancelled
  disputed('disputed');         // Dispute raised

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromString(String value) {
    for (BookingStatus status in BookingStatus.values) {
      if (status.value == value) return status;
    }
    return BookingStatus.pending;
  }
}

/// Payment status for escrow system
enum PaymentStatus {
  pending('pending'),           
  escrowed('escrowed'),        // Payment held in escrow
  released('released'),         // Payment released to provider
  refunded('refunded'),        // Payment refunded to customer
  disputed('disputed');        // Payment under dispute

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    for (PaymentStatus status in PaymentStatus.values) {
      if (status.value == value) return status;
    }
    return PaymentStatus.pending;
  }
}

/// Provider review model
class ProviderReview {
  final String id;
  final String bookingId;
  final String customerId;
  final String providerId;
  final double rating; // 1-5 stars
  final String comment;
  final List<String> images; // URLs to review images
  final DateTime createdAt;

  ProviderReview({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
  });

  factory ProviderReview.fromJson(Map<String, dynamic> json) {
    return ProviderReview(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'provider_id': providerId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Provider work sample model
class WorkSample {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String? videoUrl;
  final ServiceCategory category;
  final DateTime createdAt;

  WorkSample({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    this.imageUrls = const [],
    this.videoUrl,
    required this.category,
    required this.createdAt,
  });

  factory WorkSample.fromJson(Map<String, dynamic> json) {
    return WorkSample(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      videoUrl: json['video_url'] as String?,
      category: ServiceCategory.fromString(json['category'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'category': category.value,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Provider verification application model
class VerificationApplication {
  final String id;
  final String providerId;
  final List<ServiceCategory> requestedServices;
  final String? customServiceName;
  final String verificationVideoUrl;
  final List<String> documentUrls; // ID proof, certificates, etc.
  final String bio;
  final VerificationStatus status;
  final String? adminNotes;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  VerificationApplication({
    required this.id,
    required this.providerId,
    required this.requestedServices,
    this.customServiceName,
    required this.verificationVideoUrl,
    this.documentUrls = const [],
    required this.bio,
    this.status = VerificationStatus.pending,
    this.adminNotes,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory VerificationApplication.fromJson(Map<String, dynamic> json) {
    return VerificationApplication(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      requestedServices: (json['requested_services'] as List<dynamic>)
          .map((s) => ServiceCategory.fromString(s as String))
          .toList(),
      customServiceName: json['custom_service_name'] as String?,
      verificationVideoUrl: json['verification_video_url'] as String,
      documentUrls: (json['document_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      bio: json['bio'] as String,
      status: VerificationStatus.fromString(json['status'] as String),
      adminNotes: json['admin_notes'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'requested_services': requestedServices.map((s) => s.value).toList(),
      'custom_service_name': customServiceName,
      'verification_video_url': verificationVideoUrl,
      'document_urls': documentUrls,
      'bio': bio,
      'status': status.value,
      'admin_notes': adminNotes,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }
}

/// Verification status for provider applications
enum VerificationStatus {
  pending('pending'),
  underReview('under_review'),
  approved('approved'),
  rejected('rejected'),
  moreInfoNeeded('more_info_needed');

  const VerificationStatus(this.value);
  final String value;

  static VerificationStatus fromString(String value) {
    for (VerificationStatus status in VerificationStatus.values) {
      if (status.value == value) return status;
    }
    return VerificationStatus.pending;
  }

}
