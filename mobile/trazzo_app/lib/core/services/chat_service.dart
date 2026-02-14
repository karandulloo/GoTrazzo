import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';
import 'auth_service.dart'; // Import to access apiServiceProvider
import '../../shared/models/chat.dart';
import '../../shared/models/message.dart';

class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  // Get all chats for a business
  Future<List<Chat>> getBusinessChats(int businessId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.userChats(businessId),
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Chat.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Get all chats for a customer
  Future<List<Chat>> getCustomerChats(int customerId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.userChats(customerId),
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Chat.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Create a new chat
  Future<Chat> createChat({
    required int customerId,
    required int businessId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.createChat,
        queryParameters: {
          'customerId': customerId,
          'businessId': businessId,
        },
      );
      
      return Chat.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Get chat messages
  Future<List<Message>> getChatMessages(int chatId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.chatMessages(chatId),
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Message.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Send a message
  Future<Message> sendMessage({
    required int chatId,
    required int senderId,
    required String content,
    String type = 'TEXT',
    String? metadata,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.sendMessage,
        data: {
          'chatId': chatId,
          'senderId': senderId,
          'content': content,
          'type': type,
          if (metadata != null) 'metadata': metadata,
        },
      );
      
      return Message.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

// Riverpod provider
final chatServiceProvider = Provider<ChatService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatService(apiService);
});
