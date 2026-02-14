package com.trazzo.service;

import com.trazzo.model.Chat;
import com.trazzo.model.Message;
import com.trazzo.model.User;
import com.trazzo.model.enums.MessageType;
import com.trazzo.repository.ChatRepository;
import com.trazzo.repository.MessageRepository;
import com.trazzo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatRepository chatRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional
    public Chat getOrCreateChat(Long customerId, Long businessId) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        User business = userRepository.findById(businessId)
                .orElseThrow(() -> new RuntimeException("Business not found"));

        return chatRepository.findByCustomerAndBusiness(customer, business)
                .orElseGet(() -> {
                    Chat newChat = Chat.builder()
                            .customer(customer)
                            .business(business)
                            .build();
                    return chatRepository.save(newChat);
                });
    }

    @Transactional
    public Message sendMessage(Long chatId, Long senderId, String content, MessageType type, String metadata) {
        Chat chat = chatRepository.findById(chatId)
                .orElseThrow(() -> new RuntimeException("Chat not found"));

        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new RuntimeException("Sender not found"));

        Message message = Message.builder()
                .chat(chat)
                .sender(sender)
                .content(content)
                .type(type != null ? type : MessageType.TEXT)
                .metadata(metadata)
                .build();

        message = messageRepository.save(message);

        // Update chat last message timestamp
        chat.setLastMessageAt(LocalDateTime.now());
        chatRepository.save(chat);

        // Send via WebSocket to both customer and business
        // Send to topic for the chat (both parties subscribe to this)
        messagingTemplate.convertAndSend("/topic/chat/" + chatId, message);
        
        // Also send individual notifications
        messagingTemplate.convertAndSendToUser(
                chat.getCustomer().getId().toString(),
                "/queue/notifications",
                message);
        messagingTemplate.convertAndSendToUser(
                chat.getBusiness().getId().toString(),
                "/queue/notifications",
                message);

        return message;
    }

    public List<Message> getChatMessages(Long chatId) {
        return messageRepository.findByChatIdOrderBySentAtAsc(chatId);
    }

    public List<Chat> getUserChats(Long userId) {
        return chatRepository.findByCustomerIdOrBusinessId(userId, userId);
    }
}
