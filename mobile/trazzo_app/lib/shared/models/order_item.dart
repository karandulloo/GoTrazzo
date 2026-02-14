class OrderItem {
  final int? id;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? notes;

  OrderItem({
    this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'];
    final up = json['unitPrice'];
    final sub = json['subtotal'];
    return OrderItem(
      id: json['id'] != null ? (json['id'] is int ? json['id'] : int.tryParse('${json['id']}')) : null,
      itemName: json['itemName'] ?? '',
      quantity: qty is int ? qty : int.tryParse('$qty') ?? 0,
      unitPrice: (up is num ? up.toDouble() : double.tryParse('$up')) ?? 0,
      subtotal: (sub is num ? sub.toDouble() : double.tryParse('$sub')) ?? 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (notes != null) 'notes': notes,
      };
}
