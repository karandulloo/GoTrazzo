package com.trazzo.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AcceptOfferRequest {

    @NotNull
    private Long chatId;

    @NotNull
    private Long messageId;

    @NotNull
    private String deliveryAddress;

    @NotNull
    private Double latitude;

    @NotNull
    private Double longitude;
}
