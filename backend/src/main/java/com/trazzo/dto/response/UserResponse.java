package com.trazzo.dto.response;

import com.trazzo.model.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserResponse {
    private Long id;
    private String name;
    private String email;
    private String phone;
    private UserRole role;
    private String profileImageUrl;

    // Customer fields (default delivery address for "nearby" and orders)
    private String deliveryAddress;
    private Double defaultDeliveryLatitude;
    private Double defaultDeliveryLongitude;

    // Business fields
    private String businessName;
    private String businessDescription;
    private String category;
    private Double latitude;
    private Double longitude;
    private Double distance; // Distance in meters
}
