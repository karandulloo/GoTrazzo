package com.trazzo.controller;

import com.trazzo.dto.request.SendMessageRequest;
import com.trazzo.model.Chat;
import com.trazzo.model.Message;
import com.trazzo.service.ChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @MessageMapping("/chat.send")
    public void sendMessage(@Payload SendMessageRequest request) {
        chatService.sendMessage(
                request.getChatId(),
                request.getSenderId(),
                request.getContent(),
                request.getType(),
                request.getMetadata());
    }

    @RestController
    @RequestMapping("/api/chat")
    @RequiredArgsConstructor
    public static class ChatRestController {

        private final ChatService chatService;

        @PostMapping("/create")
        public ResponseEntity<Chat> createChat(
                @RequestParam Long customerId,
                @RequestParam Long businessId) {
            return ResponseEntity.ok(chatService.getOrCreateChat(customerId, businessId));
        }

        @GetMapping("/{chatId}/messages")
        public ResponseEntity<List<Message>> getChatMessages(@PathVariable Long chatId) {
            return ResponseEntity.ok(chatService.getChatMessages(chatId));
        }

        @GetMapping("/user/{userId}")
        public ResponseEntity<List<Chat>> getUserChats(@PathVariable Long userId) {
            return ResponseEntity.ok(chatService.getUserChats(userId));
        }

        @PostMapping("/send")
        public ResponseEntity<Message> sendMessage(@Valid @RequestBody SendMessageRequest request) {
            Message message = chatService.sendMessage(
                    request.getChatId(),
                    request.getSenderId(),
                    request.getContent(),
                    request.getType(),
                    request.getMetadata());
            return ResponseEntity.ok(message);
        }
    }
}
