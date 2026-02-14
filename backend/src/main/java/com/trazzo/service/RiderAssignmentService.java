package com.trazzo.service;

import com.trazzo.model.Order;
import com.trazzo.model.User;
import com.trazzo.model.enums.OrderStatus;
import com.trazzo.model.enums.RiderStatus;
import com.trazzo.model.enums.UserRole;
import com.trazzo.repository.OrderRepository;
import com.trazzo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Point;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RiderAssignmentService {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Value("${trazzo.rider-assignment-radius}")
    private double riderAssignmentRadius;

    @Transactional
    public Order assignRider(Order order) {
        // Find nearest available rider to business location
        Point businessLocation = order.getBusiness().getLocation();

        if (businessLocation == null) {
            throw new RuntimeException("Business location not set");
        }

        // Convert meters to degrees (approx)
        double radiusDegrees = riderAssignmentRadius / 111320.0;

        Optional<User> riderOpt = userRepository.findNearestAvailableRider(
                businessLocation,
                radiusDegrees);

        // Fallback: if no rider with location in range, assign any AVAILABLE rider (e.g. they just went Available but app hasn't sent location yet)
        if (riderOpt.isEmpty()) {
            List<User> anyAvailable = userRepository.findByRoleAndRiderStatus(UserRole.RIDER, RiderStatus.AVAILABLE);
            riderOpt = anyAvailable.isEmpty() ? Optional.empty() : Optional.of(anyAvailable.get(0));
        }

        if (riderOpt.isEmpty()) {
            // No rider available: leave order without rider, status stays PAYMENT_CONFIRMED
            order.setStatus(OrderStatus.PAYMENT_CONFIRMED);
            return orderRepository.save(order);
        }

        User rider = riderOpt.get();

        // Update order
        order.setRider(rider);
        order.setStatus(OrderStatus.RIDER_ASSIGNED);

        // Update rider status
        rider.setRiderStatus(RiderStatus.BUSY);
        userRepository.save(rider);

        orderRepository.save(order);

        // Notify rider via WebSocket
        messagingTemplate.convertAndSendToUser(
                rider.getEmail(),
                "/queue/orders",
                order);

        // Notify customer
        messagingTemplate.convertAndSendToUser(
                order.getCustomer().getEmail(),
                "/queue/orders",
                order);

        return order;
    }
}
