class Business {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? businessName;
  final String? businessDescription;
  final String? category; // e.g., "Hardware", "Groceries", "Restaurant"
  final double? latitude;
  final double? longitude;
  final String? profileImageUrl;
  final double? distance; // Distance in meters (calculated on backend)
  
  Business({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.businessName,
    this.businessDescription,
    this.category,
    this.latitude,
    this.longitude,
    this.profileImageUrl,
    this.distance,
  });
  
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      businessName: json['businessName'],
      businessDescription: json['businessDescription'],
      category: json['category'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      profileImageUrl: json['profileImageUrl'],
      distance: json['distance']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'profileImageUrl': profileImageUrl,
      'distance': distance,
    };
  }
  
  // Get display name (business name or regular name)
  String get displayName => businessName ?? name;
  
  // Format distance for display
  String get distanceDisplay {
    if (distance == null) return '';
    if (distance! < 1000) {
      return '${distance!.toStringAsFixed(0)}m';
    }
    return '${(distance! / 1000).toStringAsFixed(1)}km';
  }
}
