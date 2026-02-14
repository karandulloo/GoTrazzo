package com.trazzo.repository;

import com.trazzo.model.Chat;
import com.trazzo.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatRepository extends JpaRepository<Chat, Long> {

    Optional<Chat> findByCustomerAndBusiness(User customer, User business);

    List<Chat> findByCustomer(User customer);

    List<Chat> findByBusiness(User business);

    List<Chat> findByCustomerIdOrBusinessId(Long customerId, Long businessId);
}
