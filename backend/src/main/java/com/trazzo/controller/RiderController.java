package com.trazzo.controller;

import com.trazzo.model.Order;
import com.trazzo.model.User;
import com.trazzo.model.enums.OrderStatus;
import com.trazzo.model.enums.RiderStatus;
import com.trazzo.repository.OrderRepository;
import com.trazzo.service.RiderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rider")
@RequiredArgsConstructor
public class RiderController {

    private final RiderService riderService;
    private final OrderRepository orderRepository;

    @PutMapping("/{riderId}/status")
    public ResponseEntity<User> updateStatus(
            @PathVariable Long riderId,
            @RequestParam RiderStatus status) {
        User rider = riderService.updateRiderStatus(riderId, status);
        return ResponseEntity.ok(rider);
    }

    @PutMapping("/{riderId}/location")
    public ResponseEntity<User> updateLocation(
            @PathVariable Long riderId,
            @RequestParam double latitude,
            @RequestParam double longitude) {
        User rider = riderService.updateRiderLocation(riderId, latitude, longitude);
        return ResponseEntity.ok(rider);
    }

    @PostMapping("/orders/{orderId}/accept")
    public ResponseEntity<Order> acceptOrder(@PathVariable Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setStatus(OrderStatus.IN_TRANSIT);
        orderRepository.save(order);

        return ResponseEntity.ok(order);
    }

    @PostMapping("/orders/{orderId}/deliver")
    public ResponseEntity<Order> markDelivered(@PathVariable Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        order.setStatus(OrderStatus.DELIVERED);
        orderRepository.save(order);
        return ResponseEntity.ok(order);
    }
}
