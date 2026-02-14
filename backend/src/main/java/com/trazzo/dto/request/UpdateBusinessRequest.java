package com.trazzo.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UpdateBusinessRequest {
    private String businessName;
    private String businessDescription;
    private String category;
    private Double latitude;
    private Double longitude;
}
