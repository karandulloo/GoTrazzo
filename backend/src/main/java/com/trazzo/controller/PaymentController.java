package com.trazzo.controller;

import com.trazzo.service.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Payment webhook and config. Webhook is public (PA posts here).
 */
@RestController
@RequestMapping("/api/payment")
@RequiredArgsConstructor
@Slf4j
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/webhook")
    public ResponseEntity<Void> webhook(
            @RequestBody(required = false) String payload,
            @RequestHeader(value = "X-Razorpay-Signature", required = false) String signature) {
        log.info("Payment webhook received (mock={})", paymentService.isMockMode());
        if (!paymentService.isMockMode() && payload != null && signature != null) {
            paymentService.verifyAndProcessWebhook(payload, signature);
        }
        return ResponseEntity.ok().build();
    }

    @GetMapping("/config")
    public ResponseEntity<Map<String, Object>> config() {
        return ResponseEntity.ok(Map.of(
                "mode", paymentService.isMockMode() ? "mock" : "live"));
    }
}
