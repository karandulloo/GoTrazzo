package com.trazzo.service;

import com.trazzo.dto.request.UpdateCustomerProfileRequest;
import com.trazzo.model.User;
import com.trazzo.model.enums.UserRole;
import com.trazzo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomerService {

    private final UserRepository userRepository;

    public User getCurrentCustomer(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (user.getRole() != UserRole.CUSTOMER) {
            throw new RuntimeException("Not a customer");
        }
        return user;
    }

    public User updateProfile(String email, UpdateCustomerProfileRequest request) {
        User customer = getCurrentCustomer(email);
        if (request.getDeliveryAddress() != null) {
            customer.setDeliveryAddress(request.getDeliveryAddress());
        }
        if (request.getLatitude() != null) {
            customer.setDefaultDeliveryLatitude(request.getLatitude());
        }
        if (request.getLongitude() != null) {
            customer.setDefaultDeliveryLongitude(request.getLongitude());
        }
        return userRepository.save(customer);
    }
}
