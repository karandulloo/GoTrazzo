package com.trazzo.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.trazzo.model.Order;
import com.trazzo.model.OrderItem;
import com.trazzo.model.User;
import com.trazzo.model.Chat;
import com.trazzo.model.Message;
import com.trazzo.model.enums.MessageType;
import com.trazzo.model.enums.OrderStatus;
import com.trazzo.repository.ChatRepository;
import com.trazzo.repository.MessageRepository;
import com.trazzo.repository.OrderRepository;
import com.trazzo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ChatRepository chatRepository;
    private final MessageRepository messageRepository;
    private final RiderAssignmentService riderAssignmentService;
    private final CurrentUserService currentUserService;
    private final SimpMessagingTemplate messagingTemplate;
    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    @Value("${trazzo.rider-assignment-radius}")
    private double riderAssignmentRadius;

    @Transactional
    public Order createOrderFromOffer(Long chatId, Long offerMessageId, String deliveryAddress,
            double latitude, double longitude) {
        User customer = currentUserService.getCurrentCustomer()
                .orElseThrow(() -> new RuntimeException("Only customers can accept offers"));

        Message msg = messageRepository.findById(offerMessageId)
                .orElseThrow(() -> new RuntimeException("Offer message not found"));
        if (msg.getType() != MessageType.ORDER_PROPOSAL) {
            throw new RuntimeException("Message is not an offer");
        }
        Chat chat = msg.getChat();
        if (!chat.getId().equals(chatId)) {
            throw new RuntimeException("Offer does not belong to this chat");
        }
        if (!chat.getCustomer().getId().equals(customer.getId())) {
            throw new RuntimeException("Only the chat customer can accept this offer");
        }

        double amount = parseOfferAmount(msg.getMetadata());
        if (amount <= 0) {
            throw new RuntimeException("Invalid offer amount");
        }

        var existing = orderRepository.findByChatIdAndOfferMessageId(chatId, offerMessageId);
        if (existing.isPresent()) {
            return existing.get();
        }

        Point deliveryLocation = geometryFactory.createPoint(new Coordinate(longitude, latitude));
        Order order = Order.builder()
                .customer(customer)
                .business(chat.getBusiness())
                .chat(chat)
                .offerMessageId(offerMessageId)
                .status(OrderStatus.DRAFT)
                .deliveryAddress(deliveryAddress)
                .deliveryLocation(deliveryLocation)
                .totalAmount(BigDecimal.valueOf(amount))
                .paymentMethod("UPI_ON_DELIVERY")
                .build();

        order = orderRepository.save(order);
        riderAssignmentService.assignRider(order);
        return order;
    }

    private double parseOfferAmount(String metadata) {
        if (metadata == null || metadata.isBlank()) return 0;
        try {
            JsonNode root = OBJECT_MAPPER.readTree(metadata);
            JsonNode a = root.path("amount");
            return a.isNumber() ? a.asDouble() : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    @Transactional
    public Order createOrder(Long customerId, Long businessId, Long chatId,
            String deliveryAddress, double latitude, double longitude) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        User business = userRepository.findById(businessId)
                .orElseThrow(() -> new RuntimeException("Business not found"));
        Chat chat = chatRepository.findById(chatId)
                .orElseThrow(() -> new RuntimeException("Chat not found"));

        Point deliveryLocation = geometryFactory.createPoint(new Coordinate(longitude, latitude));

        Order order = Order.builder()
                .customer(customer)
                .business(business)
                .chat(chat)
                .status(OrderStatus.DRAFT)
                .deliveryAddress(deliveryAddress)
                .deliveryLocation(deliveryLocation)
                .build();

        return orderRepository.save(order);
    }

    @Transactional
    public Order updateOrderItems(Long orderId, List<OrderItem> items) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        // Clear existing items
        order.getItems().clear();

        // Add new items
        for (OrderItem item : items) {
            order.addItem(item);
        }

        // Calculate total
        order.calculateTotal();
        order.setStatus(OrderStatus.NEGOTIATING);

        return orderRepository.save(order);
    }

    @Transactional
    public Order confirmOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setStatus(OrderStatus.AWAITING_PAYMENT);
        return orderRepository.save(order);
    }

    @Transactional
    public Order confirmPayment(Long orderId, String paymentMethod, String transactionId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setPaymentMethod(paymentMethod);
        order.setPaymentTransactionId(transactionId);
        order.setStatus(OrderStatus.PAYMENT_CONFIRMED);
        order.setConfirmedAt(LocalDateTime.now());

        orderRepository.save(order);

        // Automatically assign rider
        riderAssignmentService.assignRider(order);

        return order;
    }

    @Transactional(readOnly = true)
    public Order getOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        if (order.getRider() != null) {
            order.getRider().getName();
            order.getRider().getPhone();
        }
        return order;
    }

    public List<Order> getCustomerOrders(Long customerId) {
        return orderRepository.findByCustomerIdOrderByCreatedAtDesc(customerId);
    }

    public List<Order> getBusinessOrders(Long businessId) {
        return orderRepository.findByBusinessIdOrderByCreatedAtDesc(businessId);
    }

    @Transactional(readOnly = true)
    public List<Order> getRiderOrders(Long riderId) {
        return orderRepository.findByRiderIdOrderByCreatedAtDesc(riderId);
    }
}
