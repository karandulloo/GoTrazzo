package com.trazzo.dto.request;

import com.trazzo.model.enums.MessageType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SendMessageRequest {

    @NotNull
    private Long chatId;

    @NotNull
    private Long senderId;

    @NotBlank
    private String content;

    private MessageType type;

    private String metadata;
}
