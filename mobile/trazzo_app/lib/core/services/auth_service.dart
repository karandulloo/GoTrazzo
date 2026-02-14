import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../constants/api_endpoints.dart';
import '../utils/token_storage.dart';
import '../../shared/models/auth_response.dart';
import '../../shared/models/user_role.dart';

class AuthService {
  final ApiService _apiService;
  
  AuthService(this._apiService);
  
  // Register user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? deliveryAddress,
    String? businessName,
    String? businessDescription,
    double? latitude,
    double? longitude,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role.value,
          if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
          if (businessName != null) 'businessName': businessName,
          if (businessDescription != null) 'businessDescription': businessDescription,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (vehicleType != null) 'vehicleType': vehicleType,
          if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
        },
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      // Save tokens
      await TokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
        userRole: authResponse.user.role.value,
      );
      
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }
  
  // Login user
  Future<AuthResponse> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {
          'emailOrPhone': emailOrPhone,
          'password': password,
        },
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      // Save tokens
      await TokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
        userRole: authResponse.user.role.value,
      );
      
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await TokenStorage.isLoggedIn();
  }
  
  // Get current user ID
  Future<int?> getCurrentUserId() async {
    return await TokenStorage.getUserId();
  }
  
  // Get current user role
  Future<UserRole?> getCurrentUserRole() async {
    final roleStr = await TokenStorage.getUserRole();
    return roleStr != null ? UserRole.fromString(roleStr) : null;
  }
}

// Riverpod provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService);
});

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
