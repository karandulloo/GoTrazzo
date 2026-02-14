import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  // Check location permissions
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }
  
  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
  
  // Get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services in Settings.');
    }
    
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please grant location permission to find nearby businesses.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable location access in Settings > Privacy > Location Services.');
    }
    
    // Add timeout to prevent hanging - wrap the entire call
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Changed from high to medium for faster response
        timeLimit: const Duration(seconds: 10), // 10 second timeout
      );
    } catch (e) {
      // If timeout or other error, throw with better message
      if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
        throw Exception('Location request timed out. Please check your GPS signal and try again.');
      }
      rethrow;
    }
  }
  
  // Get current location coordinates
  Future<Map<String, double>> getCurrentLocation() async {
    try {
      final position = await getCurrentPosition();
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      // Re-throw with more context
      if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
        throw Exception('Location request timed out. Please check your GPS signal and try again.');
      }
      rethrow;
    }
  }
  
  // Calculate distance between two points (in meters)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
