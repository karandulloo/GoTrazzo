import 'dart:convert';

class Message {
  final int id;
  final int chatId;
  final int senderId;
  final String senderName;
  final String content;
  final String type; // TEXT, ORDER_PROPOSAL, ORDER_CONFIRMATION
  final String? metadata;
  final bool isRead;
  final DateTime sentAt;

  /// For ORDER_PROPOSAL (Make an offer): amount in rupees.
  double? get offerAmount {
    if (type != 'ORDER_PROPOSAL' || metadata == null) return null;
    try {
      final m = jsonDecode(metadata!) as Map<String, dynamic>;
      final a = m['amount'];
      return a is num ? a.toDouble() : double.tryParse('$a');
    } catch (_) {
      return null;
    }
  }

  /// For ORDER_PROPOSAL: e.g. UPI_ON_DELIVERY.
  String? get offerPaymentType {
    if (type != 'ORDER_PROPOSAL' || metadata == null) return null;
    try {
      final m = jsonDecode(metadata!) as Map<String, dynamic>;
      return m['paymentType'] as String?;
    } catch (_) {
      return null;
    }
  }

  bool get isOffer => type == 'ORDER_PROPOSAL';

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    this.metadata,
    required this.isRead,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      chatId: json['chatId'] ?? json['chat']?['id'] ?? 0,
      senderId: json['senderId'] ?? json['sender']?['id'] ?? 0,
      senderName: json['senderName'] ?? json['sender']?['name'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'TEXT',
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type,
      'metadata': metadata,
      'isRead': isRead,
      'sentAt': sentAt.toIso8601String(),
    };
  }
}
