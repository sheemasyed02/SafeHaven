import 'package:latlong2/latlong.dart';

class Location {
  final String id;
  final String name;
  final String? description;
  final LatLng coordinates;
  final String? address;
  final LocationType type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Location({
    required this.id,
    required this.name,
    this.description,
    required this.coordinates,
    this.address,
    required this.type,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create Location from JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coordinates: LatLng(
        json['latitude']?.toDouble() ?? 0.0,
        json['longitude']?.toDouble() ?? 0.0,
      ),
      address: json['address'],
      type: LocationType.fromString(json['type'] ?? 'other'),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
    );
  }

  /// Convert Location to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'address': address,
      'type': type.value,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  Location copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? coordinates,
    String? address,
    LocationType? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum LocationType {
  safeHouse('safe_house'),
  emergencyService('emergency_service'),
  hospital('hospital'),
  policeStation('police_station'),
  shelter('shelter'),
  other('other');

  const LocationType(this.value);
  
  final String value;

  static LocationType fromString(String value) {
    return LocationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LocationType.other,
    );
  }
}
