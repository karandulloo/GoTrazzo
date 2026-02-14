package com.trazzo.controller;

import com.trazzo.dto.request.AcceptOfferRequest;
import com.trazzo.dto.request.OrderItemRequest;
import com.trazzo.model.Order;
import com.trazzo.model.OrderItem;
import com.trazzo.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping("/from-offer")
    public ResponseEntity<Order> createOrderFromOffer(@Valid @RequestBody AcceptOfferRequest request) {
        Order order = orderService.createOrderFromOffer(
                request.getChatId(),
                request.getMessageId(),
                request.getDeliveryAddress(),
                request.getLatitude(),
                request.getLongitude());
        return ResponseEntity.ok(order);
    }

    @PostMapping
    public ResponseEntity<Order> createOrder(
            @RequestParam Long customerId,
            @RequestParam Long businessId,
            @RequestParam Long chatId,
            @RequestParam String deliveryAddress,
            @RequestParam double latitude,
            @RequestParam double longitude) {
        Order order = orderService.createOrder(customerId, businessId, chatId,
                deliveryAddress, latitude, longitude);
        return ResponseEntity.ok(order);
    }

    @PutMapping("/{orderId}/items")
    public ResponseEntity<Order> updateOrderItems(
            @PathVariable Long orderId,
            @RequestBody List<OrderItemRequest> itemRequests) {
        List<OrderItem> items = itemRequests.stream()
                .map(req -> OrderItem.builder()
                        .itemName(req.getItemName())
                        .quantity(req.getQuantity())
                        .unitPrice(req.getUnitPrice())
                        .notes(req.getNotes())
                        .build())
                .collect(Collectors.toList());

        Order order = orderService.updateOrderItems(orderId, items);
        return ResponseEntity.ok(order);
    }

    @PostMapping("/{orderId}/confirm")
    public ResponseEntity<Order> confirmOrder(@PathVariable Long orderId) {
        Order order = orderService.confirmOrder(orderId);
        return ResponseEntity.ok(order);
    }

    @PostMapping("/{orderId}/payment")
    public ResponseEntity<Order> confirmPayment(
            @PathVariable Long orderId,
            @RequestParam String paymentMethod,
            @RequestParam String transactionId) {
        Order order = orderService.confirmPayment(orderId, paymentMethod, transactionId);
        return ResponseEntity.ok(order);
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<Order> getOrder(@PathVariable Long orderId) {
        return ResponseEntity.ok(orderService.getOrder(orderId));
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Order>> getCustomerOrders(@PathVariable Long customerId) {
        return ResponseEntity.ok(orderService.getCustomerOrders(customerId));
    }

    @GetMapping("/business/{businessId}")
    public ResponseEntity<List<Order>> getBusinessOrders(@PathVariable Long businessId) {
        return ResponseEntity.ok(orderService.getBusinessOrders(businessId));
    }

    @GetMapping("/rider/{riderId}")
    public ResponseEntity<List<Order>> getRiderOrders(@PathVariable Long riderId) {
        return ResponseEntity.ok(orderService.getRiderOrders(riderId));
    }
}
