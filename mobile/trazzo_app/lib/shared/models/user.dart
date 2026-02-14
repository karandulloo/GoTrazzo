import 'user_role.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? profileImageUrl;
  
  // Customer-specific
  final String? deliveryAddress;
  
  // Business-specific
  final String? businessName;
  final String? businessDescription;
  final double? latitude;
  final double? longitude;
  
  // Rider-specific
  final String? vehicleType;
  final String? vehicleNumber;
  final String? riderStatus; // AVAILABLE, BUSY, OFFLINE
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profileImageUrl,
    this.deliveryAddress,
    this.businessName,
    this.businessDescription,
    this.latitude,
    this.longitude,
    this.vehicleType,
    this.vehicleNumber,
    this.riderStatus,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: UserRole.fromString(json['role'] ?? 'CUSTOMER'),
      profileImageUrl: json['profileImageUrl'],
      deliveryAddress: json['deliveryAddress'],
      businessName: json['businessName'],
      businessDescription: json['businessDescription'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      riderStatus: json['riderStatus'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'profileImageUrl': profileImageUrl,
      'deliveryAddress': deliveryAddress,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'latitude': latitude,
      'longitude': longitude,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'riderStatus': riderStatus,
    };
  }
}
