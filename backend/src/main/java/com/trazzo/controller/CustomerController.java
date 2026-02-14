package com.trazzo.controller;

import com.trazzo.dto.request.UpdateCustomerProfileRequest;
import com.trazzo.dto.response.UserResponse;
import com.trazzo.model.User;
import com.trazzo.service.AuthenticationService;
import com.trazzo.service.BusinessService;
import com.trazzo.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/customer")
@RequiredArgsConstructor
public class CustomerController {

    private final BusinessService businessService;
    private final CustomerService customerService;

    @GetMapping("/profile")
    public ResponseEntity<UserResponse> getProfile(Authentication authentication) {
        User customer = customerService.getCurrentCustomer(authentication.getName());
        return ResponseEntity.ok(toUserResponse(customer));
    }

    @PutMapping("/profile")
    public ResponseEntity<UserResponse> updateProfile(
            Authentication authentication,
            @RequestBody UpdateCustomerProfileRequest request) {
        User customer = customerService.updateProfile(authentication.getName(), request);
        return ResponseEntity.ok(toUserResponse(customer));
    }

    @GetMapping("/businesses/nearby")
    public ResponseEntity<List<UserResponse>> getNearbyBusinesses(
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam(required = false) Double radius) {
        List<User> businesses = businessService.findNearbyBusinesses(latitude, longitude, radius);

        List<UserResponse> response = businesses.stream()
                .map(this::toUserResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/businesses/{id}")
    public ResponseEntity<UserResponse> getBusinessById(@PathVariable Long id) {
        User business = businessService.getBusinessById(id);
        return ResponseEntity.ok(toUserResponse(business));
    }

    private UserResponse toUserResponse(User user) {
        UserResponse.UserResponseBuilder builder = UserResponse.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .profileImageUrl(user.getProfileImageUrl())
                .deliveryAddress(user.getDeliveryAddress())
                .defaultDeliveryLatitude(user.getDefaultDeliveryLatitude())
                .defaultDeliveryLongitude(user.getDefaultDeliveryLongitude());

        if (user.getBusinessName() != null) {
            builder.businessName(user.getBusinessName())
                    .businessDescription(user.getBusinessDescription())
                    .category(user.getCategory());

            if (user.getLocation() != null) {
                builder.latitude(user.getLocation().getY())
                        .longitude(user.getLocation().getX());
            }
        }

        return builder.build();
    }
}
