import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/business_service.dart';
import '../../../core/services/customer_service.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/models/business.dart';

/// Device location with fallback - never fails.
final currentLocationProvider = FutureProvider<Map<String, double>>((ref) async {
  const defaultLocation = {'latitude': 12.9716, 'longitude': 77.5946};
  try {
    final locationService = LocationService();
    final location = await Future.any([
      locationService.getCurrentLocation(),
      Future.delayed(const Duration(seconds: 5), () => throw TimeoutException('Location timeout')),
    ]);
    return location;
  } on TimeoutException {
    return defaultLocation;
  } catch (e) {
    return defaultLocation;
  }
});

/// Location used for "nearby businesses": saved address if set, else device location.
final customerSearchLocationProvider = FutureProvider<Map<String, double>>((ref) async {
  try {
    final profile = await ref.read(customerServiceProvider).getProfile();
    if (profile.defaultDeliveryLatitude != null && profile.defaultDeliveryLongitude != null) {
      return {
        'latitude': profile.defaultDeliveryLatitude!,
        'longitude': profile.defaultDeliveryLongitude!,
      };
    }
  } catch (_) {}
  return ref.read(currentLocationProvider.future);
});

final nearbyBusinessesProvider = FutureProvider.family<List<Business>, String>((ref, locationKey) async {
  final parts = locationKey.split('_');
  final latitude = double.parse(parts[0]);
  final longitude = double.parse(parts[1]);
  final businessService = ref.watch(businessServiceProvider);
  return await businessService.findNearbyBusinesses(
    latitude: latitude,
    longitude: longitude,
  );
});
