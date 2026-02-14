import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'auth_service.dart';

final riderServiceProvider = Provider<RiderService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return RiderService(api);
});

class RiderService {
  final ApiService _api;

  RiderService(this._api);

  Future<void> updateStatus(int riderId, String status) async {
    await _api.put(
      ApiEndpoints.riderStatus(riderId),
      queryParameters: {'status': status},
    );
  }

  Future<void> updateLocation(int riderId, double lat, double lng) async {
    await _api.put(
      ApiEndpoints.riderLocation(riderId),
      queryParameters: {'latitude': lat, 'longitude': lng},
    );
  }
}
