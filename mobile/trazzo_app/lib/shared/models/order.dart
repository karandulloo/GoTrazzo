import 'order_item.dart';

class Order {
  final int id;
  final int customerId;
  final String? customerName;
  final int businessId;
  final String? businessName;
  final int? riderId;
  final String? riderName;
  final String? riderPhone;
  final int chatId;
  final String status;
  final List<OrderItem> items;
  final double? totalAmount;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? paymentMethod;
  final String? paymentTransactionId;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.businessId,
    this.businessName,
    this.riderId,
    this.riderName,
    this.riderPhone,
    required this.chatId,
    required this.status,
    required this.items,
    this.totalAmount,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.paymentMethod,
    this.paymentTransactionId,
    this.createdAt,
    this.confirmedAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final cust = json['customer'];
    final biz = json['business'];
    final rider = json['rider'];
    final chat = json['chat'];
    double? lat;
    double? lng;
    final loc = json['deliveryLocation'];
    if (loc is Map) {
      final coords = loc['coordinates'];
      if (coords is List && coords.length >= 2) {
        lng = (coords[0] is num) ? (coords[0] as num).toDouble() : double.tryParse('${coords[0]}');
        lat = (coords[1] is num) ? (coords[1] as num).toDouble() : double.tryParse('${coords[1]}');
      }
    }

    final itemsList = json['items'];
    final itemMaps = itemsList is List ? itemsList : <dynamic>[];
    final parsed = itemMaps.map<OrderItem>((e) {
      final m = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
      return OrderItem.fromJson(m);
    }).toList();

    final total = json['totalAmount'];
    return Order(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      customerId: _idFrom(cust) ?? int.tryParse('${json['customerId']}') ?? 0,
      customerName: _nameFrom(cust) ?? json['customerName'],
      businessId: _idFrom(biz) ?? int.tryParse('${json['businessId']}') ?? 0,
      businessName: _nameFrom(biz) ?? json['businessName'],
      riderId: rider != null ? _idFrom(rider) : null,
      riderName: rider != null ? _nameFrom(rider) : json['riderName'],
      riderPhone: rider != null ? _phoneFrom(rider) : json['riderPhone'],
      chatId: _idFrom(chat) ?? int.tryParse('${json['chatId']}') ?? 0,
      status: json['status'] ?? 'DRAFT',
      items: parsed,
      totalAmount: total is num ? total.toDouble() : double.tryParse('$total'),
      deliveryAddress: json['deliveryAddress'] ?? '',
      deliveryLat: lat,
      deliveryLng: lng,
      paymentMethod: json['paymentMethod'],
      paymentTransactionId: json['paymentTransactionId'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      confirmedAt: json['confirmedAt'] != null ? DateTime.tryParse(json['confirmedAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt']) : null,
    );
  }

  static int? _idFrom(dynamic o) {
    if (o == null) return null;
    if (o is Map) {
      final v = o['id'];
      return v is int ? v : int.tryParse('$v');
    }
    return null;
  }

  static String? _nameFrom(dynamic o) {
    if (o == null) return null;
    if (o is Map) return o['name'] ?? o['businessName'];
    return null;
  }

  static String? _phoneFrom(dynamic o) {
    if (o == null) return null;
    if (o is Map) return o['phone'] as String?;
    return null;
  }

  bool get isDraft => status == 'DRAFT';
  bool get isNegotiating => status == 'NEGOTIATING';
  bool get isAwaitingPayment => status == 'AWAITING_PAYMENT';
  bool get isPaymentConfirmed => status == 'PAYMENT_CONFIRMED';
  bool get isRiderAssigned => status == 'RIDER_ASSIGNED';
  bool get isInTransit => status == 'IN_TRANSIT';
  bool get isDelivered => status == 'DELIVERED';
  bool get isCancelled => status == 'CANCELLED';

  String get statusDisplay {
    switch (status) {
      case 'DRAFT':
        return 'Draft';
      case 'PENDING_BUSINESS':
        return 'Pending business';
      case 'NEGOTIATING':
        return 'Negotiating';
      case 'AWAITING_PAYMENT':
        return 'Awaiting payment';
      case 'PAYMENT_CONFIRMED':
        return 'Payment confirmed';
      case 'RIDER_ASSIGNED':
        return 'Rider assigned';
      case 'IN_TRANSIT':
        return 'In transit';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
