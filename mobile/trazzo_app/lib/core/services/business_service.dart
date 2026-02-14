import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'api_service.dart';
import 'auth_service.dart'; // Import to access apiServiceProvider
import '../constants/api_endpoints.dart';
import '../../shared/models/business.dart';

class BusinessService {
  final ApiService _apiService;
  
  BusinessService(this._apiService);
  
  // Find nearby businesses
  Future<List<Business>> findNearbyBusinesses({
    required double latitude,
    required double longitude,
    double? radius, // in meters, defaults to 5000 (5km)
  }) async {
    try {
      // Add timeout wrapper to prevent hanging
      final response = await _apiService.get(
        ApiEndpoints.nearbyBusinesses,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          if (radius != null) 'radius': radius,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out. Please check your connection and try again.');
        },
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Business.fromJson(json))
            .toList();
      }
      
      // If response is not a list, return empty list
      return [];
    } on DioException catch (e) {
      // Handle Dio errors specifically
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Please check if backend is running.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Please check your permissions.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please check if backend is running correctly.');
      } else if (e.response?.statusCode != null) {
        throw Exception('Server error (${e.response?.statusCode}). Please try again later.');
      }
      throw Exception('Failed to load businesses: ${e.message}');
    } catch (e) {
      // Handle any other errors
      if (e.toString().contains('timeout')) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }
  
  // Get business details by ID
  Future<Business> getBusinessById(int id) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.businessDetails(id),
      );
      
      return Business.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update business profile
  Future<Business> updateBusinessProfile({
    String? businessName,
    String? businessDescription,
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateBusinessProfile,
        data: {
          if (businessName != null) 'businessName': businessName,
          if (businessDescription != null) 'businessDescription': businessDescription,
          if (category != null) 'category': category,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
      
      return Business.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

// Riverpod provider
final businessServiceProvider = Provider<BusinessService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BusinessService(apiService);
});
