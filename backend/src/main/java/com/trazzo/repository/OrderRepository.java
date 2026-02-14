package com.trazzo.repository;

import com.trazzo.model.Order;
import com.trazzo.model.User;
import com.trazzo.model.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByCustomerOrderByCreatedAtDesc(User customer);

    List<Order> findByBusinessOrderByCreatedAtDesc(User business);

    List<Order> findByRiderOrderByCreatedAtDesc(User rider);

    List<Order> findByCustomerIdOrderByCreatedAtDesc(Long customerId);

    List<Order> findByBusinessIdOrderByCreatedAtDesc(Long businessId);

    List<Order> findByRiderIdOrderByCreatedAtDesc(Long riderId);

    List<Order> findByStatus(OrderStatus status);

    List<Order> findByStatusIn(List<OrderStatus> statuses);

    java.util.Optional<Order> findByChatIdAndOfferMessageId(Long chatId, Long offerMessageId);
}
