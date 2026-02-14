class Chat {
  final int id;
  final int customerId;
  final String customerName;
  final String? customerEmail;
  final int businessId;
  final String businessName;
  final DateTime? lastMessageTime;
  final String? lastMessage;
  final int? unreadCount;

  Chat({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    required this.businessId,
    required this.businessName,
    this.lastMessageTime,
    this.lastMessage,
    this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? json['chatId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? json['customer']?['name'] ?? '',
      customerEmail: json['customerEmail'] ?? json['customer']?['email'],
      businessId: json['businessId'] ?? 0,
      businessName: json['businessName'] ?? json['business']?['name'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      lastMessage: json['lastMessage'],
      unreadCount: json['unreadCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'businessId': businessId,
      'businessName': businessName,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
    };
  }
}
