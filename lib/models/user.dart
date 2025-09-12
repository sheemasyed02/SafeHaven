class User {
  final String id;
  final String email;
  final String? name; // Add name field to match database
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? role; // Added role field
  final String? providerType; // Added provider type field
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.role,
    this.providerType,
    required this.createdAt,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      role: json['role'],
      providerType: json['provider_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'role': role,
      'provider_type': providerType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get full name
  String get fullName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    } else if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }

  /// Create copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? role,
    String? providerType,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      providerType: providerType ?? this.providerType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
