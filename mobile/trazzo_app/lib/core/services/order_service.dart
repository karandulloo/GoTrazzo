import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../../shared/models/order.dart';
import '../../shared/models/order_item.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return OrderService(api);
});

class OrderService {
  final ApiService _api;

  OrderService(this._api);

  Future<Order> createOrder({
    required int customerId,
    required int businessId,
    required int chatId,
    required String deliveryAddress,
    required double latitude,
    required double longitude,
  }) async {
    final res = await _api.post(
      ApiEndpoints.orders,
      queryParameters: {
        'customerId': customerId,
        'businessId': businessId,
        'chatId': chatId,
        'deliveryAddress': deliveryAddress,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Accept a chat offer: create order, assign rider. Customer must be authenticated.
  Future<Order> createOrderFromOffer({
    required int chatId,
    required int messageId,
    required String deliveryAddress,
    required double latitude,
    required double longitude,
  }) async {
    final res = await _api.post(
      ApiEndpoints.ordersFromOffer,
      data: {
        'chatId': chatId,
        'messageId': messageId,
        'deliveryAddress': deliveryAddress,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> getOrder(int orderId) async {
    final res = await _api.get(ApiEndpoints.orderDetails(orderId));
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<Order>> getCustomerOrders(int customerId) async {
    final res = await _api.get(ApiEndpoints.customerOrders(customerId));
    final list = res.data is List ? res.data as List : <dynamic>[];
    return list.map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<Order>> getBusinessOrders(int businessId) async {
    final res = await _api.get(ApiEndpoints.businessOrders(businessId));
    final list = res.data is List ? res.data as List : <dynamic>[];
    return list.map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<Order>> getRiderOrders(int riderId) async {
    final res = await _api.get(ApiEndpoints.riderOrders(riderId));
    final list = res.data is List ? res.data as List : <dynamic>[];
    return list.map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Order> updateOrderItems(int orderId, List<OrderItem> items) async {
    final body = items.map((e) => e.toJson()).toList();
    final res = await _api.put(ApiEndpoints.orderItems(orderId), data: body);
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> confirmOrder(int orderId) async {
    final res = await _api.post(ApiEndpoints.confirmOrder(orderId));
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> confirmPayment(int orderId, {String paymentMethod = 'UPI_MOCK', String? transactionId}) async {
    final res = await _api.post(
      ApiEndpoints.orderPayment(orderId),
      queryParameters: {
        'paymentMethod': paymentMethod,
        'transactionId': transactionId ?? 'TXN${DateTime.now().millisecondsSinceEpoch}',
      },
    );
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> riderAcceptOrder(int orderId) async {
    final res = await _api.post(ApiEndpoints.acceptOrder(orderId));
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> riderMarkDelivered(int orderId) async {
    final res = await _api.post(ApiEndpoints.markDelivered(orderId));
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
