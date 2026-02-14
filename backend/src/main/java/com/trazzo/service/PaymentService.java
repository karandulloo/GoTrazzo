package com.trazzo.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Payment integration (Razorpay / Cashfree). Mock mode when keys are not set.
 */
@Service
@Slf4j
public class PaymentService {

    @Value("${RAZORPAY_KEY_ID:}")
    private String razorpayKeyId;

    @Value("${RAZORPAY_KEY_SECRET:}")
    private String razorpayKeySecret;

    @Value("${PAYMENT_WEBHOOK_SECRET:}")
    private String webhookSecret;

    public boolean isMockMode() {
        return razorpayKeyId == null || razorpayKeyId.isBlank()
                || razorpayKeySecret == null || razorpayKeySecret.isBlank();
    }

    public Optional<String> getWebhookSecret() {
        return (webhookSecret != null && !webhookSecret.isBlank())
                ? Optional.of(webhookSecret)
                : Optional.empty();
    }

    /**
     * Create a PA order for the given amount (in rupees). Mock mode returns null.
     */
    public String createPaymentOrder(Long orderId, double amountRupees) {
        if (isMockMode()) {
            log.info("Payment mock: create order for orderId={} amount={}", orderId, amountRupees);
            return null;
        }
        // TODO: Razorpay Orders API – create order, return order_id for checkout
        return null;
    }

    /**
     * Verify webhook signature and process payment.paid / order.paid. Mock mode skips verify.
     */
    public boolean verifyAndProcessWebhook(String payload, String signature) {
        if (isMockMode()) {
            log.info("Payment mock: webhook ignored (no keys)");
            return false;
        }
        if (!getWebhookSecret().isPresent()) {
            log.warn("Payment webhook: PAYMENT_WEBHOOK_SECRET not set");
            return false;
        }
        // TODO: Verify HMAC signature, parse payload, update order payment status
        return false;
    }
}
