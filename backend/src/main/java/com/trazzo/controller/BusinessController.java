package com.trazzo.controller;

import com.trazzo.dto.request.UpdateBusinessRequest;
import com.trazzo.dto.response.UserResponse;
import com.trazzo.model.User;
import com.trazzo.service.BusinessService;
import com.trazzo.service.AuthenticationService;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.locationtech.jts.geom.Point;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/business")
@RequiredArgsConstructor
public class BusinessController {

    private final BusinessService businessService;
    private final AuthenticationService authenticationService;
    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    @PutMapping("/profile")
    public ResponseEntity<UserResponse> updateBusinessProfile(
            @RequestBody UpdateBusinessRequest request,
            Authentication authentication) {
        
        String email = authentication.getName();
        User business = authenticationService.getUserByEmail(email);
        
        if (business.getRole() != com.trazzo.model.enums.UserRole.BUSINESS) {
            return ResponseEntity.badRequest().build();
        }
        
        // Update business fields
        if (request.getBusinessName() != null) {
            business.setBusinessName(request.getBusinessName());
        }
        if (request.getBusinessDescription() != null) {
            business.setBusinessDescription(request.getBusinessDescription());
        }
        if (request.getCategory() != null) {
            business.setCategory(request.getCategory());
        }
        if (request.getLatitude() != null && request.getLongitude() != null) {
            Point location = geometryFactory.createPoint(
                    new org.locationtech.jts.geom.Coordinate(
                            request.getLongitude(), 
                            request.getLatitude()));
            business.setLocation(location);
        }
        
        User updatedBusiness = businessService.updateBusiness(business);
        
        return ResponseEntity.ok(toUserResponse(updatedBusiness));
    }

    @GetMapping("/profile")
    public ResponseEntity<UserResponse> getBusinessProfile(Authentication authentication) {
        String email = authentication.getName();
        User business = authenticationService.getUserByEmail(email);
        
        if (business.getRole() != com.trazzo.model.enums.UserRole.BUSINESS) {
            return ResponseEntity.badRequest().build();
        }
        
        return ResponseEntity.ok(toUserResponse(business));
    }

    private UserResponse toUserResponse(User user) {
        UserResponse.UserResponseBuilder builder = UserResponse.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .profileImageUrl(user.getProfileImageUrl());

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
