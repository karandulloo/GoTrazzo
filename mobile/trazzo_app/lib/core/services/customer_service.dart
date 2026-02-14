import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../constants/api_endpoints.dart';
import '../../shared/models/user.dart';

class CustomerService {
  final ApiService _api;

  CustomerService(this._api);

  Future<User> getProfile() async {
    final res = await _api.get(ApiEndpoints.customerProfile);
    return User.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<User> updateProfile({
    String? deliveryAddress,
    double? latitude,
    double? longitude,
  }) async {
    final res = await _api.put(
      ApiEndpoints.customerProfile,
      data: {
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    return User.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}

final customerServiceProvider = Provider<CustomerService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return CustomerService(api);
});
